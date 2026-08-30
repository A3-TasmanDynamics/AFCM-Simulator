/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Preset Library's Delete button. Only enabled for a selected user
 * MCI preset (fnc_mciPresetLibrary_onSelect.sqf) - built-in ones never enable this, and
 * fnc_deleteUserMciPreset.sqf itself refuses a "builtin_" id too.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Delete button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlDelete"];

private _display = ctrlParent _ctrlDelete;
private _index = lbCurSel (_display displayCtrl 10);
if (_index == -1) exitWith {};

private _id = (_display displayCtrl 10) lbData _index;
[_id] call afcm_sim_scenario_fnc_deleteUserMciPreset;

[_display] call afcm_sim_ui_fnc_mciPresetLibrary_populateList;
