/*
 * Author: Tasman Dynamics
 * Registers this backend with afcm_sim_main. Runs at this addon's own preInit — the engine
 * guarantees every addon's preInit finishes before any addon's postInit runs (where selection
 * happens, afcm_sim_main's postInit), regardless of load order between compat addons. Registers
 * at a lower priority than kat_compat so KAT wins when present, per DESIGN.md §2.5.
 *
 * Also registers the "afcm_sim_ace_applyFractureLocal" CBA event here (not afcm_sim_main) - unlike
 * the shared injury-application event, this one is ACE-only (kat_compat never fires or registers
 * it), so there's no risk of the double-registration afcm_sim_main_fnc_medical_
 * registerEvents.sqf's own comment warns about. Referencing afcm_sim_ace_fnc_applyFractureLocal
 * here is safe even though this script runs at preInit - CfgFunctions compiles every function in
 * this addon's own tag before any of its preInit code executes, the same reason this file already
 * safely references its own afcm_sim_ace_fnc_applyInjury etc. below.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

["afcm_sim_ace_applyFractureLocal", afcm_sim_ace_fnc_applyFractureLocal] call CBA_fnc_addEventHandler;

private _interface = createHashMap;
_interface set ["applyInjury", afcm_sim_ace_fnc_applyInjury];
_interface set ["removeInjury", afcm_sim_ace_fnc_removeInjury];
_interface set ["getState", afcm_sim_ace_fnc_getState];
_interface set ["reset", afcm_sim_ace_fnc_reset];
_interface set ["setUnconscious", afcm_sim_ace_fnc_setUnconscious];

["ace", 10, _interface] call afcm_sim_fnc_backend_registerBackend;
