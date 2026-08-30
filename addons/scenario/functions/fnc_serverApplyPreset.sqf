/*
 * Author: Tasman Dynamics
 * Server-side handler for applying a whole preset (DESIGN.md §4.3/§ Injury Presets) to a patient -
 * the "preset" source in the "one application pipeline, three sources: manual, preset, randomized"
 * framing (DESIGN.md §5). Called via remoteExec from afcm_sim_ui's Preset Library dialog.
 *
 * Deliberately just loops the same afcm_sim_scenario_fnc_serverApplyInjury every manual injury
 * already goes through, one call per injury entry, rather than duplicating its Injury-construction
 * logic (bleedRate roll, tourniquetable derivation) here - same real backend dispatch either way,
 * one preset just means several injuries applied in one request instead of one.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Injuries <ARRAY of [limb, woundType, severity, bleeding]> - see fnc_getBuiltinPresets.sqf
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_injuries"];

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};

{
    _x params ["_limb", "_woundType", ["_severity", 0.5], ["_bleeding", false]];
    [_unit, _limb, _woundType, _severity, _bleeding] call afcm_sim_scenario_fnc_serverApplyInjury;
} forEach _injuries;
