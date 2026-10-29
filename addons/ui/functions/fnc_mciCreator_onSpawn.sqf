/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Creator's Spawn MCI button. Stays disabled
 * (fnc_mciCreator_refreshLocationStatus.sqf) until AFCM_SIM_UI_mciLocation is actually set, so the
 * guard here is defensive, not the primary safeguard. remoteExecs the whole incident to the server
 * in one request (afcm_sim_scenario_fnc_serverSpawnMci) - never spawns locally (DESIGN.md §6).
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Spawn MCI button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlSpawn"];

private _display = ctrlParent _ctrlSpawn;

private _pos = missionNamespace getVariable ["AFCM_SIM_UI_mciLocation", []];
if (_pos isEqualTo []) exitWith {
    diag_log text "[AFCM-Simulator][UI] MCI Spawn aborted - no location set.";
};

private _casualtyType = lbCurSel (_display displayCtrl 11);
if (_casualtyType == -1) then { _casualtyType = 0; };
AFCM_SIM_UI_mciCasualtyType = _casualtyType;

private _sessionLabel = ctrlText (_display displayCtrl 23);
private _radius = missionNamespace getVariable ["AFCM_SIM_UI_mciRadius", 10];

diag_log text format ["[AFCM-Simulator][UI] Spawning MCI - %1 patient(s) at %2 (casualtyType=%3, radius=%4).", count AFCM_SIM_UI_mciPatientSpecs, _pos, _casualtyType, _radius];

[_pos, AFCM_SIM_UI_mciPatientSpecs, _casualtyType, _sessionLabel, _radius] remoteExec ["afcm_sim_scenario_fnc_serverSpawnMci", 2];

// Real, confirmed bug fixed here: AFCM_SIM_UI_mciPatientSpecs (fnc_mciCreator_init.sqf) is only
// ever seeded once per session (isNil guard) and nothing else resets it - so reopening MCI Creator
// for a genuinely different incident silently reused whichever presets were last assigned, even
// after the first incident's patients were cleared via the Session Manager (which only touches
// spawned objects/sessions server-side, never this dialog's own working state). The remoteExec
// above already serialized the real specs for THIS spawn, so resetting the var now only affects
// future opens, not this call - preserves "reopen to tweak before spawning" within one incident
// while guaranteeing a spawned incident's presets never leak into the next one.
AFCM_SIM_UI_mciPatientSpecs = AFCM_SIM_UI_mciPatientSpecs apply { "random" };

closeDialog 0;
