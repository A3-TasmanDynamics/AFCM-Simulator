/*
 * Author: Tasman Dynamics
 * ButtonClick handler for RscDisplayAFCM_SIM_SpawnPatientPicker's Spawn Patient button.
 *
 * Persists the chosen Casualty Type to profileNamespace (AFCM_SIM_lastSpawnPatientCasualtyType) -
 * the real "remember my last choice" mechanism fnc_spawnPatientPicker_init.sqf reads back on the
 * NEXT module placement, on request. Then remoteExecs the real spawn
 * (afcm_sim_spawner_fnc_spawnPatient, DESIGN.md §6 - never spawns locally), passing clientOwner so
 * the server callbacks straight back to afcm_sim_ui_fnc_injuryAuthor_open once the unit exists -
 * same "auto-open Edit Injuries after spawning" flow this module already had.
 *
 * Clears AFCM_SIM_UI_spawnPatientPickerLogic to objNull BEFORE deleting it here, so
 * fnc_spawnPatientPicker_cleanup.sqf's own onUnload delete (which handles the Cancel/Escape case)
 * sees it already gone and doesn't try to delete an already-deleted object.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Spawn Patient button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlSpawn"];

disableSerialization;
private _display = ctrlParent _ctrlSpawn;

private _casualtyType = lbCurSel (_display displayCtrl 10);
if (_casualtyType == -1) then { _casualtyType = 0; };

profileNamespace setVariable ["AFCM_SIM_lastSpawnPatientCasualtyType", _casualtyType];
saveProfileNamespace;

private _logic = missionNamespace getVariable ["AFCM_SIM_UI_spawnPatientPickerLogic", objNull];
private _pos = missionNamespace getVariable ["AFCM_SIM_UI_spawnPatientPickerPos", []];
private _sessionLabel = missionNamespace getVariable ["AFCM_SIM_UI_spawnPatientPickerSessionLabel", ""];

if (_pos isNotEqualTo []) then {
    [_pos, [], _casualtyType, "", _sessionLabel, [], clientOwner] remoteExec ["afcm_sim_spawner_fnc_spawnPatient", 2];
};

missionNamespace setVariable ["AFCM_SIM_UI_spawnPatientPickerLogic", objNull];
if !(isNull _logic) then { deleteVehicle _logic; };

closeDialog 0;
