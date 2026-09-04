/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's Import button. Reads whatever's in the shared
 * Import/Export text field and parses it via afcm_sim_scenario_fnc_parseExportedPreset - accepts
 * either real export shape (the full Preset envelope, or the bare injuries/[injuries, katExtras]
 * shape fnc_exportPatientState.sqf/this dialog's own Export produce) - and, on success, overwrites
 * the whole staged set with it.
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

disableSerialization;
private _display = ctrlParent _ctrlImport;

private _text = ctrlText (_display displayCtrl 46);
private _cleaned = [_text] call afcm_sim_scenario_fnc_parseExportedPreset;

if (_cleaned isEqualTo []) exitWith {
    ["Injury Author", "Couldn't parse that - paste a string from Export or the Preset Library."] call afcm_sim_ui_fnc_showToast;
};

_cleaned params ["", "_injuries", "", "", "", "_katExtras"];

missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", _injuries];
missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", if (_katExtras isEqualTo []) then { [[0, 0, 0, 0, 0, 0], 0, 0, 0] } else { _katExtras }];

call afcm_sim_ui_fnc_injuryAuthor_refreshActiveLimbForm;
call afcm_sim_ui_fnc_injuryAuthor_refreshNavbar;

["Injury Author", format ["Imported %1 injuries.", count _injuries]] call afcm_sim_ui_fnc_showToast;
