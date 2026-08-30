/*
 * Author: Tasman Dynamics
 * Opens the Session Manager (RscDisplayAFCM_SIM_SessionManager) - the real entry point for
 * managing Spawn Sessions, callable directly (`call afcm_sim_ui_fnc_sessionManager_open;`) and
 * bound to a real CBA keybind (afcm_sim_fnc_registerSessionManagerKeybind, default Ctrl+Shift+O),
 * as well as reachable from the MCI Creator's own "Manage Sessions" button.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Bool - result of createDialog
 *
 * Public: Yes
*/

createDialog "RscDisplayAFCM_SIM_SessionManager"
