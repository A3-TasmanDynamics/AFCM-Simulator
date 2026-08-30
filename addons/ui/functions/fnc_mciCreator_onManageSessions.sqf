/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Creator's "Manage Sessions" button. Opens the Session Manager
 * (RscDisplayAFCM_SIM_SessionManager) on top of this dialog - doesn't close the Creator, the two
 * just stack (same pattern as Save as Preset/Load MCI Preset opening on top of it).
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Manage Sessions button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlBtn"];

call afcm_sim_ui_fnc_sessionManager_open;
