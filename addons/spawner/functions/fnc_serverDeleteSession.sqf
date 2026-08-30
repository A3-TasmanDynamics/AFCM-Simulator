/*
 * Author: Tasman Dynamics
 * Deletes every patient belonging to one Spawn Session (DESIGN.md § Spawn Sessions) - and only
 * that session - without touching any other session's patients or `AFCM_SIM_spawnedPatients`
 * entries outside it. The whole point of sessions: e.g. two medics each working their own MCI at
 * once, one gets cleared, the other's patients stay untouched. Server-authoritative (DESIGN.md
 * §6), same as afcm_sim_spawner_fnc_clearAllPatients.
 *
 * Removes the session's units from AFCM_SIM_spawnedPatients too, so that list and
 * AFCM_SIM_spawnSessions never drift out of sync with each other.
 *
 * Arguments:
 * 0: Session id <STRING>
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_sessionId"];

if !(isServer) exitWith {};

private _sessions = missionNamespace getVariable ["AFCM_SIM_spawnSessions", []];
private _sessionIdx = _sessions findIf { (_x select 0) == _sessionId };
if (_sessionIdx == -1) exitWith {};

private _units = (_sessions select _sessionIdx) select 3;

{
    if (!isNull _x && { _x getVariable ["AFCM_SIM_isPatient", false] }) then {
        deleteVehicle _x;
    };
} forEach _units;

_sessions deleteAt _sessionIdx;
AFCM_SIM_spawnSessions = _sessions;
publicVariable "AFCM_SIM_spawnSessions";

AFCM_SIM_spawnedPatients = (missionNamespace getVariable ["AFCM_SIM_spawnedPatients", []]) - _units;
publicVariable "AFCM_SIM_spawnedPatients";

diag_log text format ["[AFCM-Simulator] Deleted session '%1' - %2 patient(s) removed.", _sessionId, count _units];
