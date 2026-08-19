/*
 * Author: Tasman Dynamics
 * Button handler for the limb-selection dialog (RscDisplayAFCM_SIM_LimbSelect). Publishes
 * "limb.selected" on the UI event bus (DESIGN.md §5) and closes the dialog.
 *
 * Arguments:
 * 0: LimbId <STRING> - see DESIGN.md §4.1 (head / torso / armLeft / armRight / legLeft / legRight)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_limbId"];

["limb.selected", [_limbId]] call afcm_sim_ui_fnc_publish;

closeDialog 0;
