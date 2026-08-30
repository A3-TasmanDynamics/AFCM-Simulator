/*
 * Author: Tasman Dynamics
 * Fills the MCI Preset Library's listbox with built-in (fnc_getBuiltinMciPresets.sqf) then user
 * (fnc_getUserMciPresets.sqf) MCI presets, each row reading
 * "[Built-in/User] <name> (N patients)" and tagged with the real MCI preset id via `lbSetData` -
 * same pattern as fnc_presetLibrary_populateList.sqf, for MCI presets.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_MciPresetLibrary <DISPLAY>
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
    params ["_list", "_mciPreset"];
    _mciPreset params ["_id", "_name", "", "", "_patientSpecs"];
    private _prefix = ["[User] ", "[Built-in] "] select (_id find "builtin_" == 0);
    private _plural = ["", "s"] select (count _patientSpecs != 1);
    private _idx = _list lbAdd format ["%1%2 (%3 patient%4)", _prefix, _name, count _patientSpecs, _plural];
    _list lbSetData [_idx, _id];
};

{ [_list, _x] call _fnc_addRow; } forEach (call afcm_sim_scenario_fnc_getBuiltinMciPresets);
{ [_list, _x] call _fnc_addRow; } forEach (call afcm_sim_scenario_fnc_getUserMciPresets);

(_display displayCtrl 11) ctrlEnable false;
(_display displayCtrl 12) ctrlEnable false;
(_display displayCtrl 13) ctrlEnable false;
