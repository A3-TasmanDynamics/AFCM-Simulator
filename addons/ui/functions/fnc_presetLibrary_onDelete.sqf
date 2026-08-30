/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Preset Library's Delete button (RscDisplayAFCM_SIM_PresetLibrary).
 * Only enabled for a selected user preset (fnc_presetLibrary_onSelect.sqf - built-in presets never
 * enable this button, and fnc_deleteUserPreset.sqf itself refuses to delete a "builtin_" id too,
 * so this is safe even if triggered some other way).
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
[_id] call afcm_sim_scenario_fnc_deleteUserPreset;

[_display] call afcm_sim_ui_fnc_presetLibrary_populateList;
