/*
 * Author: Tasman Dynamics
 * Registers this backend with afcm_sim_main. Runs at this addon's own preInit — the engine
 * guarantees every addon's preInit finishes before any addon's postInit runs (where selection
 * happens, afcm_sim_main's postInit), regardless of load order between compat addons. Registers
 * at a lower priority than afcm_compat/kat_compat so AFCM/KAT win when present, per DESIGN.md §2.5.
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
_interface set ["applyInjury", afcm_sim_ace_fnc_applyInjury];
_interface set ["removeInjury", afcm_sim_ace_fnc_removeInjury];
_interface set ["getState", afcm_sim_ace_fnc_getState];
_interface set ["reset", afcm_sim_ace_fnc_reset];
_interface set ["setUnconscious", afcm_sim_ace_fnc_setUnconscious];

["ace", 10, _interface] call afcm_sim_fnc_backend_registerBackend;
