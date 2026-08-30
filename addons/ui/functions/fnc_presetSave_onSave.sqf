/*
 * Author: Tasman Dynamics
 * ButtonClick handler for RscDisplayAFCM_SIM_PresetSave's Save button. Reads the entered name and
 * the pending injury stashed by fnc_injuryEditor_onSavePreset.sqf
 * (AFCM_SIM_UI_pendingPresetInjuries), saves it via afcm_sim_scenario_fnc_saveUserPreset - client-
 * side (profileNamespace), not a server request, since this never touches a patient - then closes.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Save button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlSave"];

private _display = ctrlParent _ctrlSave;
private _name = ctrlText (_display displayCtrl 10);

if (_name isEqualTo "") exitWith {
    diag_log text "[AFCM-Simulator][UI] Save Preset aborted - no name entered.";
};

private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_pendingPresetInjuries", []];
if (_injuries isEqualTo []) exitWith {
    diag_log text "[AFCM-Simulator][UI] Save Preset aborted - no pending injury to save.";
};

[_name, _injuries] call afcm_sim_scenario_fnc_saveUserPreset;

closeDialog 0;
