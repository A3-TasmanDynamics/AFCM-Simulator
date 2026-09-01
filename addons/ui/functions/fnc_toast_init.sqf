/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_Toast (ui/config.cpp) - pulls the title/body text
 * afcm_sim_ui_fnc_showToast stashed in missionNamespace right before calling cutRsc and writes it
 * into the two controls. Self-contained (no round trip back to showToast) so there's no timing race
 * between cutRsc creating the layer and the caller trying to touch its controls.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_Toast <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display"];

(_display displayCtrl 1) ctrlSetText (missionNamespace getVariable ["AFCM_SIM_UI_toastTitle", "AFCM"]);
(_display displayCtrl 2) ctrlSetText (missionNamespace getVariable ["AFCM_SIM_UI_toastBody", ""]);
