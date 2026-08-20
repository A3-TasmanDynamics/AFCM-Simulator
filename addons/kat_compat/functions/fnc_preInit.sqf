/*
 * Author: Tasman Dynamics
 * Registers this backend with afcm_sim_main. Runs at this addon's own preInit — the engine
 * guarantees every addon's preInit finishes before any addon's postInit runs (where selection
 * happens, afcm_sim_main's postInit), regardless of load order between compat addons. Registers
 * at a higher priority than afcm_sim_ace_compat — KAT's model should win over vanilla ACE3
 * whenever KAT is actually present (DESIGN.md §2.5).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

private _interface = createHashMap;
_interface set ["applyInjury", afcm_sim_kat_fnc_applyInjury];
_interface set ["removeInjury", afcm_sim_kat_fnc_removeInjury];

["kat", 15, _interface] call afcm_sim_fnc_backend_registerBackend;
