/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Preset Library's Import button (RscDisplayAFCM_SIM_PresetLibrary).
 * Reads whatever's in the shared text field (idc 14 - paste via Ctrl+V is native OS edit-box
 * behaviour, nothing scripted needed for that half) and hands it to
 * afcm_sim_scenario_fnc_importPreset, which parses/validates it and saves it as a new user preset.
 * Refreshes the list on success so the new entry shows up immediately.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Import button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlImport"];

private _display = ctrlParent _ctrlImport;
private _text = ctrlText (_display displayCtrl 14);

private _result = [_text] call afcm_sim_scenario_fnc_importPreset;

if (_result isEqualTo []) exitWith {
    diag_log text "[AFCM-Simulator][UI] Preset import failed - empty, malformed, or not a valid preset string.";
};

diag_log text format ["[AFCM-Simulator][UI] Imported preset '%1'.", _result select 1];

[_display] call afcm_sim_ui_fnc_presetLibrary_populateList;
