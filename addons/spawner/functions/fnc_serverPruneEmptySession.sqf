/*
 * Author: Tasman Dynamics
 * Removes one Spawn Session (DESIGN.md § Spawn Sessions) from AFCM_SIM_spawnSessions once every
 * patient in it is gone, regardless of HOW they went - this mod's own Session Manager "Delete
 * Session"/"Clear All Sessions" buttons already remove the session entry themselves
 * (fnc_serverDeleteSession.sqf/fnc_clearAllPatients.sqf), but a patient deleted any OTHER way (Zeus's
 * own native delete/trash tool, a scripted deleteVehicle elsewhere in the mission, simply dying and
 * being cleaned up by something else) bypassed both of those entirely - nothing ever told
 * AFCM_SIM_spawnSessions that unit was gone, so a session could sit at 0 real patients forever,
 * stuck "active" in the Session Manager list with no real way to remove just it. Real, confirmed
 * report: deleting patients in Zeus down to 0 left the session behind.
 *
 * Called from a per-patient "Deleted" event handler (fnc_spawnPatient.sqf) - a real, confirmed
 * vanilla entity event (not MP-specific, not a kill) that fires for ANY removal regardless of
 * source, which `killed`/MPKilled would miss for a straight Zeus deleteVehicle (no death occurs).
 *
 * Real, confirmed bug fixed here: this used to check `isNull` on the OTHER units still tracked in
 * the session to decide whether this was the last one gone - correct for one deletion at a time, but
 * a real retest proved it wrong for a multi-select Zeus delete (several patients in the same session
 * removed in the same instant): EVERY one of their "Deleted" handlers fired with the OTHERS still
 * reading `!isNull` at that exact moment (their own deletions hadn't "landed" as null yet, even
 * though all were genuinely being deleted together), so every single check in a 4-patient batch saw
 * "3 still alive" - including the very last one - and the session never pruned. Fixed by having each
 * call EXPLICITLY remove its own `_justDeleted` unit from the session's tracked list and write that
 * back immediately, rather than polling `isNull` on units whose own deletions may not have reached
 * this unit's own handler yet - this is authoritative (SQF's own handlers still run one at a time,
 * so each call's removal is guaranteed to land before the next one's check) where `isNull` wasn't.
 *
 * Arguments:
 * 0: Session id <STRING>
 * 1: Just-deleted unit <OBJECT> (default objNull) - removed from the session's tracked list
 *    unconditionally, regardless of its own isNull status at this exact moment
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_sessionId", ["_justDeleted", objNull]];

if !(isServer) exitWith {};

private _sessions = missionNamespace getVariable ["AFCM_SIM_spawnSessions", []];
private _sessionIdx = _sessions findIf { (_x select 0) == _sessionId };
if (_sessionIdx == -1) exitWith {
    diag_log text format ["[AFCM-Simulator][diag] serverPruneEmptySession - session '%1' not found in AFCM_SIM_spawnSessions, nothing to prune.", _sessionId];
};

private _session = _sessions select _sessionIdx;
// Explicit removal of _justDeleted plus a cheap isNull sweep for anything else already gone -
// never relies on _justDeleted's own isNull status, same reasoning the old version already had for
// excluding it, now extended to actually mutate the tracked list instead of just filtering a
// throwaway local copy.
private _remaining = (_session select 3) select { _x != _justDeleted && !(isNull _x) };
_session set [3, _remaining];
_sessions set [_sessionIdx, _session];
AFCM_SIM_spawnSessions = _sessions;
publicVariable "AFCM_SIM_spawnSessions";

diag_log text format ["[AFCM-Simulator][diag] serverPruneEmptySession - session '%1': %2 remaining after removing %3.", _sessionId, count _remaining, _justDeleted];

if (_remaining isNotEqualTo []) exitWith {};

_sessions deleteAt _sessionIdx;
AFCM_SIM_spawnSessions = _sessions;
publicVariable "AFCM_SIM_spawnSessions";

AFCM_SIM_spawnedPatients = (missionNamespace getVariable ["AFCM_SIM_spawnedPatients", []]) select { !(isNull _x) && {_x != _justDeleted} };
publicVariable "AFCM_SIM_spawnedPatients";

diag_log text format ["[AFCM-Simulator] Spawn Session '%1' auto-pruned - every patient in it is gone.", _sessionId];
