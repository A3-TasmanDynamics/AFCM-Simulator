/*
 * Author: Tasman Dynamics
 * Starts the single, shared Medical Tent completion monitor - one server-side loop covering every
 * registered stretcher (AFCM_SIM_medicalStretchers) and every Spawn Session
 * (AFCM_SIM_spawnSessions, afcm_sim_spawner) at once, rather than one loop per placed tent.
 * Idempotent by convention - afcm_sim_scenario_fnc_registerMedicalTent only calls this once
 * (AFCM_SIM_medicalTentMonitorStarted guard), the first time any Medical Tent module registers.
 *
 * A session is "resolved" the moment every one of its still-alive units is simultaneously treated
 * (afcm_sim_scenario_fnc_isPatientTreated) and on a stretcher (afcm_sim_scenario_fnc_
 * isPatientOnStretcher) - checked once every 5s, plain vanilla `spawn`/`sleep` loop rather than
 * CBA_fnc_addPerFrameHandler, since this is server-only bookkeeping with no per-frame UI to update
 * (unlike fnc_injuryEditor_refreshState.sqf's use of that API for a live-open dialog). Resolved
 * sessions are tracked in AFCM_SIM_resolvedSessionIds so the notification only ever fires once per
 * session, even if a patient later leaves the stretcher radius.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

if !(isServer) exitWith {};

if (isNil "AFCM_SIM_resolvedSessionIds") then { AFCM_SIM_resolvedSessionIds = []; };

[] spawn {
    while { true } do {
        private _stretchers = missionNamespace getVariable ["AFCM_SIM_medicalStretchers", []];
        if (_stretchers isNotEqualTo []) then {
            {
                _x params ["_sessionId", "_sessionLabel", "_spawnTime", "_units"];

                if !(_sessionId in AFCM_SIM_resolvedSessionIds) then {
                    private _liveUnits = _units select { !(isNull _x) };

                    if (_liveUnits isNotEqualTo []) then {
                        private _allDone = (_liveUnits findIf {
                            !([_x] call afcm_sim_scenario_fnc_isPatientTreated)
                            || {!([_x, _stretchers] call afcm_sim_scenario_fnc_isPatientOnStretcher)}
                        }) == -1;

                        if (_allDone) then {
                            AFCM_SIM_resolvedSessionIds pushBack _sessionId;
                            [_sessionId, _sessionLabel, count _liveUnits] remoteExec ["afcm_sim_ui_fnc_notifySessionResolved", 0, true];
                        };
                    };
                };
            } forEach (missionNamespace getVariable ["AFCM_SIM_spawnSessions", []]);
        };
        sleep 5;
    };
};
