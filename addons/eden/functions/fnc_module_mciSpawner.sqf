/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleMciSpawnerPlacement (Eden). Spawns a batch of patients at the
 * module's position on mission start, all with the exact same real Injury Preset applied
 * (DESIGN.md § Map to Spawn Patients / MCI, INJURY_CODES.md §4) - distinct from AFCM MASCAL Zone
 * (fnc_module_mascalZone.sqf), which rolls a randomized injury set per patient from an Injury
 * Level instead of a specific, curated preset.
 *
 * Preset is picked at design time via a static Attribute (only the 5 built-in presets - a
 * mission-authored Eden module can't reference a specific player's own future profileNamespace
 * user presets, since those are per-player and wouldn't resolve consistently for anyone else who
 * plays the mission). Unlike Zeus's version (afcm_sim_zeus_fnc_module_mciSpawner), no interactive
 * dialog is needed here at all - mission start isn't a live "someone just placed this" moment tied
 * to one specific client the way Zeus placement is, so everything has to be fully resolved from
 * config already.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed module
 * 1: Units <ARRAY> - synced units, if any
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_logic", "_units", "_activated"];

if !(_activated) exitWith {};
if !(isServer) exitWith {};

private _patientCount = _logic getVariable ["AFCM_SIM_patientCount", 4];
private _casualtyType = _logic getVariable ["AFCM_SIM_casualtyType", afcm_sim_defaultCasualtyType];
// Index into afcm_sim_scenario_fnc_getBuiltinPresets's own array order - keep the Preset
// Attribute's Values (eden/config.cpp) in sync with that order if it ever changes.
private _presetIndex = _logic getVariable ["AFCM_SIM_mciPreset", 0];
private _pos = getPosASL _logic;

private _presets = call afcm_sim_scenario_fnc_getBuiltinPresets;
private _preset = _presets param [_presetIndex, _presets select 0];
private _injuries = _preset select 4;

for "_i" from 1 to _patientCount do {
    [_pos, _injuries, _casualtyType] call afcm_sim_spawner_fnc_spawnPatient;
};
