/*
 * Author: Tasman Dynamics
 * Registers this backend with afcm_sim_scenario. Runs at this addon's own preInit — guaranteed to
 * happen before selection (which waits for "CBA_addons_postInit"). Registers at a lower priority
 * than the AFCM-native backend so AFCM wins when both are present, per DESIGN.md §2.5.
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

["ace", 10, _interface] call afcm_sim_fnc_backend_registerBackend;
