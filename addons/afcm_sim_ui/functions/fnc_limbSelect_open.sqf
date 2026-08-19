/*
 * Author: Tasman Dynamics
 * Opens the limb-selection dialog (DESIGN.md §5 "Selectable Body Limbs"). Selecting a limb
 * publishes "limb.selected" on the UI event bus and closes the dialog — this dialog never calls
 * afcm_sim_scenario directly (DESIGN.md §3).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Bool - result of createDialog
 *
 * Public: Yes
*/

createDialog "RscDisplayAFCM_SIM_LimbSelect"
