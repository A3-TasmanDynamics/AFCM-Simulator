/*
 * Author: Tasman Dynamics
 * Opens RscDisplayAFCM_SIM_SpawnPatientPicker - the Zeus Spawn Patient module's real picker window
 * (on request - "it must open a window to choose the faction and unit type of the patient first").
 * Called from fnc_module_spawnRandomPatient.sqf, local-curator-gated the same way
 * AFCM_SIM_ModuleMciSpawner/ModuleEditInjuries already open their own dialogs on just the placing
 * curator's own screen.
 *
 * Stashes the module logic + spawn position in plain missionNamespace vars (same convention every
 * other dialog here uses, e.g. fnc_injuryAuthor_open.sqf's AFCM_SIM_UI_targetUnit) rather than
 * threading them through dialog params, since RscDisplay dialogs don't take arguments.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed Zeus module, not deleted yet
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_logic"];

if (isNull _logic) exitWith {};

missionNamespace setVariable ["AFCM_SIM_UI_spawnPatientPickerLogic", _logic];
missionNamespace setVariable ["AFCM_SIM_UI_spawnPatientPickerPos", getPosASL _logic];
// Optional Session Name attribute (DESIGN.md § Spawn Sessions) - read off the module now, before
// fnc_spawnPatientPicker_onSpawn.sqf/cleanup.sqf delete it, so a non-blank one still reaches the
// real spawn the same way it always has.
missionNamespace setVariable ["AFCM_SIM_UI_spawnPatientPickerSessionLabel", _logic getVariable ["AFCM_SIM_sessionName", ""]];

createDialog "RscDisplayAFCM_SIM_SpawnPatientPicker";
