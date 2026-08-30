/*
 * Author: Tasman Dynamics
 * Resolves one MCI patient spec (fnc_getBuiltinMciPresets.sqf - either the literal string "random"
 * or a real Preset id) into a real Injuries array of Injury HashMaps
 * (afcm_sim_scenario_fnc_buildInjury), ready to hand straight to
 * afcm_sim_spawner_fnc_spawnPatient. Never baked into the stored MciPreset itself - "random" is
 * re-rolled fresh every time an MCI is actually spawned.
 *
 * Arguments:
 * 0: Patient spec <STRING> - "random", or a real Preset id
 *
 * Return Value:
 * Injuries <ARRAY of HASHMAP>
 *
 * Public: Yes
*/

params ["_spec"];

if (_spec isEqualTo "random") exitWith {
    [afcm_sim_defaultInjuryLevel] call afcm_sim_scenario_fnc_randomizeInjuries
};

private _preset = [_spec] call afcm_sim_scenario_fnc_findPreset;
if (_preset isEqualTo []) exitWith { [] };

(_preset select 4) apply {
    _x params ["_limb", "_woundType", ["_severity", 0.5], ["_bleeding", false]];
    [_limb, _woundType, _severity, _bleeding] call afcm_sim_scenario_fnc_buildInjury
}
