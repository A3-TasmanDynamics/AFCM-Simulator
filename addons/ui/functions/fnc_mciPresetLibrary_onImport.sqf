/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Preset Library's Import button. Reads whatever's in the shared
 * text field (paste via Ctrl+V is native OS edit-box behaviour) and hands it to
 * afcm_sim_scenario_fnc_importMciPreset, which parses/validates it and saves it as a new user MCI
 * preset. Refreshes the list on success.
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

private _result = [_text] call afcm_sim_scenario_fnc_importMciPreset;

if (_result isEqualTo []) exitWith {
    diag_log text "[AFCM-Simulator][UI] MCI preset import failed - empty, malformed, or not a valid MCI preset string.";
};

diag_log text format ["[AFCM-Simulator][UI] Imported MCI preset '%1'.", _result select 1];

[_display] call afcm_sim_ui_fnc_mciPresetLibrary_populateList;
