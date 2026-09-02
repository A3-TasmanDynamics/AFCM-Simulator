/*
 * Author: Tasman Dynamics
 * Registers this backend with afcm_sim_main. Runs at this addon's own preInit — the engine
 * guarantees every addon's preInit finishes before any addon's postInit runs (where selection
 * happens, afcm_sim_main's postInit), regardless of load order between compat addons. Registers
 * at a higher priority than afcm_sim_ace_compat — KAT's model should win over vanilla ACE3
 * whenever KAT is actually present (DESIGN.md §2.5).
 *
 * Also registers the CBA event afcm_sim_kat_fnc_applyPneumothorax dispatches to
 * (afcm_sim_applyKatPneumothoraxLocal) - real fix for kat_breathing_fnc_handleBreathing/
 * kat_circulation_fnc_updateInternalBleeding needing to run on whichever machine the target unit
 * is actually local to, same reasoning as afcm_sim_ace_fnc_applyInjury's own dispatch (see
 * fnc_applyPneumothorax.sqf's header). preInit, not postInit, same reasoning as
 * afcm_sim_main_fnc_medical_registerEvents.sqf - just subscribes to CBA's event system, which
 * doesn't depend on backend registration/selection at all.
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
_interface set ["getState", afcm_sim_kat_fnc_getState];
_interface set ["reset", afcm_sim_kat_fnc_reset];
_interface set ["setUnconscious", afcm_sim_kat_fnc_setUnconscious];

["kat", 15, _interface] call afcm_sim_fnc_backend_registerBackend;

["afcm_sim_applyKatPneumothoraxLocal", afcm_sim_kat_fnc_applyPneumothoraxLocal] call CBA_fnc_addEventHandler;
