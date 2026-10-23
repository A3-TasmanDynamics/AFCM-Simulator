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
 * `_justDeleted` is passed through explicitly rather than relying on `isNull` on the unit that
 * fired this - its own validity at the exact instant its own "Deleted" handler runs isn't something
 * to depend on either way.
 *
 * Arguments:
 * 0: Session id <STRING>
 * 1: Just-deleted unit <OBJECT> (default objNull) - excluded from the "anyone still alive" check
 *    regardless of its own isNull status at this exact moment
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

private _units = (_sessions select _sessionIdx) select 3;
private _stillAlive = _units select { !(isNull _x) && {_x != _justDeleted} };
// Diagnostic-only, temporary - a prior retest still showed the session not auto-clearing at 0
// patients despite this function's own logic looking correct; logged unconditionally so a next
// retest shows exactly what this function saw (every tracked unit, and which ones it judged alive).
diag_log text format ["[AFCM-Simulator][diag] serverPruneEmptySession - session '%1': %2 tracked unit(s), %3 still alive (excluding %4).", _sessionId, count _units, count _stillAlive, _justDeleted];
if (_stillAlive isNotEqualTo []) exitWith {};

_sessions deleteAt _sessionIdx;
AFCM_SIM_spawnSessions = _sessions;
publicVariable "AFCM_SIM_spawnSessions";

AFCM_SIM_spawnedPatients = (missionNamespace getVariable ["AFCM_SIM_spawnedPatients", []]) select { !(isNull _x) && {_x != _justDeleted} };
publicVariable "AFCM_SIM_spawnedPatients";

diag_log text format ["[AFCM-Simulator] Spawn Session '%1' auto-pruned - every patient in it is gone.", _sessionId];
