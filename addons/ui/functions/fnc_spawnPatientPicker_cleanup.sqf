/*
 * Author: Tasman Dynamics
 * onUnload handler for RscDisplayAFCM_SIM_SpawnPatientPicker - runs regardless of how the dialog
 * closed (Spawn Patient, Cancel, or Escape), same "cleanup runs no matter how it closed" reasoning
 * fnc_mapPicker_cleanup.sqf already documents.
 *
 * Deletes the stashed module logic if it's still here - covers Cancel/Escape, where
 * fnc_spawnPatientPicker_onSpawn.sqf's own delete never ran. Treats cancelling the picker as
 * abandoning that placement entirely (deletes the module either way, same "disappears straight
 * away" spirit the Medical Terminal module's own enforcement already has) rather than leaving a
 * dead module icon behind to re-trigger the picker later.
 *
 * fnc_spawnPatientPicker_onSpawn.sqf already clears AFCM_SIM_UI_spawnPatientPickerLogic to objNull
 * before deleting it itself, so this is a no-op in that case - only the Cancel/Escape path actually
 * deletes anything here.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

private _logic = missionNamespace getVariable ["AFCM_SIM_UI_spawnPatientPickerLogic", objNull];

if !(isNull _logic) then {
    deleteVehicle _logic;
};

missionNamespace setVariable ["AFCM_SIM_UI_spawnPatientPickerLogic", nil];
missionNamespace setVariable ["AFCM_SIM_UI_spawnPatientPickerPos", nil];
missionNamespace setVariable ["AFCM_SIM_UI_spawnPatientPickerSessionLabel", nil];
