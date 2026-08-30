/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Creator's "Save as MCI Preset" button. Opens
 * RscDisplayAFCM_SIM_MciPresetSave on top of this dialog to name and save the current
 * AFCM_SIM_UI_mciPatientSpecs as a reusable MCI preset - doesn't touch anything else here, the
 * name dialog reads AFCM_SIM_UI_mciPatientSpecs directly.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Save as MCI Preset button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlBtn"];

createDialog "RscDisplayAFCM_SIM_MciPresetSave";
