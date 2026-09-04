/*
 * Author: Tasman Dynamics
 * Builds a real Injury HashMap (DESIGN.md §4.2) from the 4 lightweight primitives used everywhere
 * else in this addon (Preset injury entries, serverApplyInjury's own remoteExec'd args) - the same
 * bleedRate roll / tourniquetable derivation afcm_sim_scenario_fnc_serverApplyInjury used to do
 * inline, factored out here so anything that needs to pre-resolve injuries before calling
 * afcm_sim_spawner_fnc_spawnPatient (whose Injuries argument requires real Injury HashMaps, not
 * the lighter [limb, woundType, severity, bleeding] shape) can reuse it instead of duplicating the
 * logic - or, the real bug this fixes, passing the lighter shape directly where a HashMap is
 * required. Confirmed real RPT error this caused: "Error getordefault: Type Array, expected
 * HashMap" in ace_compat/kat_compat's fnc_applyInjury.sqf, from afcm_sim_eden_fnc_module_mciSpawner
 * handing a preset's raw injuries array straight to spawnPatient.
 *
 * Arguments:
 * 0: LimbId <STRING>
 * 1: woundType <STRING>
 * 2: Severity <NUMBER> (default 0.5)
 * 3: Bleeding <BOOL> (default false)
 * 4: bleedRate <NUMBER> (default -1) - explicit bleed rate, e.g. from the injury author dialog's
 *    Light/Medium/Heavy/Severe combo. -1 is a sentinel meaning "not specified" - keeps the original
 *    random-roll behaviour below for any caller that predates this (old preset entries, old
 *    exported strings), so nothing needs migrating.
 *
 * Return Value:
 * Injury <HASHMAP>
 *
 * Public: Yes
*/

params ["_limb", "_woundType", ["_severity", 0.5], ["_bleeding", false], ["_bleedRate", -1]];

// Same 4 limbs as afcm_sim_scenario_fnc_randomizeInjuries - only arms/legs are tourniquetable,
// never head/chest.
private _tourniquetableLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];
if (_bleedRate < 0) then {
    _bleedRate = if (_bleeding) then { 0.1 + random 0.3 } else { 0 };
};

private _injury = createHashMap;
_injury set ["limb", _limb];
_injury set ["woundType", _woundType];
_injury set ["severity", _severity];
_injury set ["bleeding", _bleeding];
_injury set ["bleedRate", _bleedRate];
_injury set ["tourniquetable", _limb in _tourniquetableLimbs];
_injury set ["variables", createHashMap];
_injury
