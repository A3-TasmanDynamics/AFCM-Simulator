/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's "Choose Location on Map" button
 * (author-new-patient mode only). Opens the Map Picker (RscDisplayAFCM_SIM_MapPicker) on top of
 * this dialog - doesn't close it, the two just stack, same pattern as the MCI Creator's own
 * "Choose Location on Map" (fnc_mciCreator_onChooseLocation.sqf). fnc_mapPicker_onConfirm.sqf tells
 * this dialog apart from the MCI Creator by checking which one of the two is actually open
 * (findDisplay 25605 vs 25611) before deciding which target variable to write into.
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
