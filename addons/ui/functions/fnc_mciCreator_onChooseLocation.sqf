/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Creator's "Choose Location on Map" button. Opens the Map Picker
 * (RscDisplayAFCM_SIM_MapPicker) on top of this dialog - doesn't close the Creator, the two just
 * stack (same pattern as the injury editor's Save as Preset opening on top of it).
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Choose Location button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlBtn"];

createDialog "RscDisplayAFCM_SIM_MapPicker";
