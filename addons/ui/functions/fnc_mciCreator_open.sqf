/*
 * Author: Tasman Dynamics
 * Opens the MCI Creator (RscDisplayAFCM_SIM_MciCreator) - the real entry point for the whole
 * feature, callable directly (`call afcm_sim_ui_fnc_mciCreator_open;`) and bound to a real CBA
 * keybind (afcm_sim_fnc_registerMciCreatorKeybind, default Ctrl+Shift+M). Doesn't require a Zeus/
 * Eden module to be placed first, unlike the module-based MCI Spawners.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Bool - result of createDialog
 *
 * Public: Yes
*/

createDialog "RscDisplayAFCM_SIM_MciCreator"
