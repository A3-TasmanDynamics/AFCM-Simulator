/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Creator's "Load MCI Preset" button. Opens
 * RscDisplayAFCM_SIM_MciPresetLibrary on top of this dialog - picking one there and clicking Load
 * replaces AFCM_SIM_UI_mciPatientSpecs wholesale (fnc_mciPresetLibrary_onLoad.sqf).
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Load MCI Preset button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlBtn"];

createDialog "RscDisplayAFCM_SIM_MciPresetLibrary";
