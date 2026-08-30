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
 * Real, confirmed bug fixed here: this used to hand the preset's raw `injuries` entries
 * ([limb, woundType, severity, bleeding] Arrays, INJURY_CODES.md §4) straight to
 * afcm_sim_spawner_fnc_spawnPatient, whose Injuries argument requires real Injury HashMaps
 * (DESIGN.md §4.2) - confirmed from a live RPT log: "Error getordefault: Type Array, expected
 * HashMap" in ace_compat/kat_compat's fnc_applyInjury.sqf. Each entry is now resolved through
 * afcm_sim_scenario_fnc_buildInjury (the same HashMap-construction afcm_sim_scenario_fnc_
 * serverApplyInjury itself uses) before being passed on.
 *
 * Also guards against firing more than once per placed module (`AFCM_SIM_moduleFired`,
 * a variable stashed on `_logic` itself) - vanilla Module_F's function has no guaranteed
 * single-fire behaviour (confirmed independently by ACE3's own Modules Framework docs, which
 * built their own wrapper specifically because "there is no guarantee" here), and re-firing
 * would otherwise spawn duplicate patient batches silently.
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
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};
_logic setVariable ["AFCM_SIM_moduleFired", true];

private _patientCount = _logic getVariable ["AFCM_SIM_patientCount", 4];
private _casualtyType = _logic getVariable ["AFCM_SIM_casualtyType", afcm_sim_defaultCasualtyType];
// Index into afcm_sim_scenario_fnc_getBuiltinPresets's own array order - keep the Preset
// Attribute's Values (eden/config.cpp) in sync with that order if it ever changes.
private _presetIndex = _logic getVariable ["AFCM_SIM_mciPreset", 0];
private _pos = getPosASL _logic;

private _presets = call afcm_sim_scenario_fnc_getBuiltinPresets;
private _preset = _presets param [_presetIndex, _presets select 0];
private _injuries = (_preset select 4) apply {
    _x params ["_limb", "_woundType", ["_severity", 0.5], ["_bleeding", false]];
    [_limb, _woundType, _severity, _bleeding] call afcm_sim_scenario_fnc_buildInjury
};

for "_i" from 1 to _patientCount do {
    [_pos, _injuries, _casualtyType] call afcm_sim_spawner_fnc_spawnPatient;
};
