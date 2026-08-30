/*
 * Author: Tasman Dynamics
 * Looks up one preset (built-in or user-saved) by id across both libraries -
 * fnc_getBuiltinPresets.sqf and fnc_getUserPresets.sqf - so the UI layer doesn't need to merge and
 * search both lists itself every time it needs the full preset behind a listbox selection.
 *
 * Arguments:
 * 0: Id <STRING>
 *
 * Return Value:
 * Preset <ARRAY>, or [] if no preset with that id exists
 *
 * Public: Yes
*/

params ["_id"];

private _match = ((call afcm_sim_scenario_fnc_getBuiltinPresets) + (call afcm_sim_scenario_fnc_getUserPresets)) select { (_x select 0) == _id };

if (_match isEqualTo []) exitWith { [] };
_match select 0
