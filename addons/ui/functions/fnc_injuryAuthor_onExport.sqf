/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's Export button. Commits the active limb's form
 * first, then builds an export string directly from the staged arrays
 * (afcm_sim_scenario_fnc_exportInjuries - same bare-array shape fnc_exportPatientState.sqf's own
 * clipboard export uses), writes it into the shared Import/Export text field, and copies it to the
 * OS clipboard.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Export button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlExport"];

call afcm_sim_ui_fnc_injuryAuthor_commitActiveLimbForm;

disableSerialization;
private _display = ctrlParent _ctrlExport;

private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];
private _katExtras = missionNamespace getVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];

if (_injuries isEqualTo [] && {_katExtras isEqualTo [[0, 0, 0, 0, 0, 0], 0, 0, 0]}) exitWith {
    ["Injury Author", "Nothing staged to export yet."] call afcm_sim_ui_fnc_showToast;
};

private _exported = [_injuries, _katExtras] call afcm_sim_scenario_fnc_exportInjuries;

(_display displayCtrl 46) ctrlSetText _exported;
copyToClipboard _exported;

["Injury Author", "Copied to clipboard."] call afcm_sim_ui_fnc_showToast;
