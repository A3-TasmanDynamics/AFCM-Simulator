/*
 * Author: Tasman Dynamics
 * ButtonClick handler for RscDisplayAFCM_SIM_MciPresetSave's Save button. Reads the entered name
 * and saves the MCI Creator's current AFCM_SIM_UI_mciPatientSpecs via
 * afcm_sim_scenario_fnc_saveUserMciPreset - client-side (profileNamespace), not a server request,
 * since this never touches a patient - then closes.
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
    diag_log text "[AFCM-Simulator][UI] Save MCI Preset aborted - no name entered.";
};

private _specs = missionNamespace getVariable ["AFCM_SIM_UI_mciPatientSpecs", []];
if (_specs isEqualTo []) exitWith {
    diag_log text "[AFCM-Simulator][UI] Save MCI Preset aborted - no patients configured.";
};

[_name, _specs] call afcm_sim_scenario_fnc_saveUserMciPreset;

closeDialog 0;
