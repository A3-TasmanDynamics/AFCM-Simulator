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

diag_log text format ["[AFCM-Simulator][UI] Spawning MCI - %1 patient(s) at %2 (casualtyType=%3).", count AFCM_SIM_UI_mciPatientSpecs, _pos, _casualtyType];

[_pos, AFCM_SIM_UI_mciPatientSpecs, _casualtyType, _sessionLabel] remoteExec ["afcm_sim_scenario_fnc_serverSpawnMci", 2];

closeDialog 0;
