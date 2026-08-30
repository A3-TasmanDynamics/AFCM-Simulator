/*
 * Author: Tasman Dynamics
 * Fills the Preset Library's listbox (RscDisplayAFCM_SIM_PresetLibrary) with built-in
 * (fnc_getBuiltinPresets.sqf) then user (fnc_getUserPresets.sqf) presets - split out from
 * fnc_presetLibrary_init.sqf so fnc_presetLibrary_onDelete.sqf/fnc_presetLibrary_onImport.sqf can
 * refresh the list after a change without re-registering the dialog's ButtonClick/LBSelChanged
 * event handlers a second time (ctrlAddEventHandler adds, it doesn't replace - calling the full
 * init function again on every refresh would stack up duplicate handlers).
 *
 * Stashes each row's real preset id via `lbSetData` (real command - associates a string with a
 * listbox row, read back with `lbData`) so later handlers can look the exact preset up without
 * re-parsing the display text.
 *
 * Also sets the Subtitle to reflect batch (MCI) vs single-patient mode, based on whether
 * AFCM_SIM_UI_targetUnits (plural) is non-empty - see fnc_presetLibrary_onApply.sqf for how that
 * variable actually drives which one Apply does.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_PresetLibrary <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display"];

disableSerialization;

private _list = _display displayCtrl 10;
lbClear _list;

private _fnc_addRow = {
    params ["_list", "_preset"];
    _preset params ["_id", "_name", "", "", "_injuries"];
    private _prefix = ["[User] ", "[Built-in] "] select (_id find "builtin_" == 0);
    private _plural = ["", "s"] select (count _injuries != 1);
    private _idx = _list lbAdd format ["%1%2 (%3 injury%4)", _prefix, _name, count _injuries, _plural];
    _list lbSetData [_idx, _id];
};

{ [_list, _x] call _fnc_addRow; } forEach (call afcm_sim_scenario_fnc_getBuiltinPresets);
{ [_list, _x] call _fnc_addRow; } forEach (call afcm_sim_scenario_fnc_getUserPresets);

(_display displayCtrl 11) ctrlEnable false;
(_display displayCtrl 12) ctrlEnable false;
(_display displayCtrl 13) ctrlEnable false;

private _targetUnits = missionNamespace getVariable ["AFCM_SIM_UI_targetUnits", []];
private _subtitle = if (_targetUnits isNotEqualTo []) then {
    format ["MCI batch — select a preset to apply to all %1 patient(s)", count _targetUnits]
} else {
    "Apply a saved injury set, or export/import one below"
};
(_display displayCtrl 17) ctrlSetText _subtitle;
