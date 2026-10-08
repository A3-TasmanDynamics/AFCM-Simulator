/*
 * Author: Tasman Dynamics
 * Runs backend selection. Marked postInit=1 in CfgFunctions — the engine guarantees every addon's
 * preInit (where backend registration happens, see fnc_backend_registerBackend.sqf) has already
 * run by the time ANY addon's postInit runs, regardless of load order between addons. See
 * DESIGN.md §2.5/§6.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

call afcm_sim_fnc_backend_selectBackend;

// Diagnostic-only, temporary - added to chase down a "Zeus modules don't show/do nothing" report
// that two static code reviews couldn't reproduce (every historically-fixed Zeus bug already has
// its fix present in the current config). Runs once per client at postInit regardless of whether
// any Zeus module is ever placed, so it still reports even if the modules never make it into the
// curator browser at all. Remove once the real cause is confirmed from RPT and fixed.
{
    diag_log text format ["[AFCM-Simulator][diag] CfgPatches '%1' loaded: %2", _x, isClass (configFile >> "CfgPatches" >> _x)];
} forEach ["afcm_sim_zeus", "afcm_sim_main", "afcm_sim_scenario", "afcm_sim_spawner", "cba_main"];
{
    diag_log text format ["[AFCM-Simulator][diag] CfgVehicles '%1' exists: %2, scopeCurator=%3, function=%4", _x, isClass (configFile >> "CfgVehicles" >> _x), getNumber (configFile >> "CfgVehicles" >> _x >> "scopeCurator"), getText (configFile >> "CfgVehicles" >> _x >> "function")];
} forEach ["AFCM_SIM_ModuleSpawnRandomPatient", "AFCM_SIM_ModuleMciSpawner", "AFCM_SIM_ModuleEditInjuries"];
diag_log text format ["[AFCM-Simulator][diag] CfgFactionClasses 'AFCM_SIM_Category' exists: %1", isClass (configFile >> "CfgFactionClasses" >> "AFCM_SIM_Category")];
