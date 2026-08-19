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
