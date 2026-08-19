/*
 * Author: Tasman Dynamics
 * Bootstraps backend selection. Runs at this addon's own preInit; registers a handler for
 * "CBA_addons_postInit", which fires once every addon's own preInit (where backend registration
 * happens, see fnc_backend_registerBackend.sqf) has already run — guaranteeing every candidate
 * backend has had a chance to register before selection happens. See DESIGN.md §2.5/§6.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

["CBA_addons_postInit", {
    call afcm_sim_fnc_backend_selectBackend;
}] call CBA_fnc_addEventHandler;
