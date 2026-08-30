/*
 * Author: Tasman Dynamics
 * Looks up one MCI preset (built-in or user-saved) by id across both libraries - same pattern as
 * fnc_findPreset.sqf, for MCI presets instead of single-injury ones.
 *
 * Arguments:
 * 0: Id <STRING>
 *
 * Return Value:
 * MciPreset <ARRAY>, or [] if no MCI preset with that id exists
 *
 * Public: Yes
*/

params ["_id"];

private _match = ((call afcm_sim_scenario_fnc_getBuiltinMciPresets) + (call afcm_sim_scenario_fnc_getUserMciPresets)) select { (_x select 0) == _id };

if (_match isEqualTo []) exitWith { [] };
_match select 0
