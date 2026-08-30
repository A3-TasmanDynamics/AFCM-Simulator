/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Creator's "Randomize All Patients" button. Sets every patient's
 * spec back to "random" - a quick way to reset the whole incident to fully-randomized before
 * hand-picking specific presets for just the patients that need them.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Randomize All button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlBtn"];

private _display = ctrlParent _ctrlBtn;

AFCM_SIM_UI_mciPatientSpecs = AFCM_SIM_UI_mciPatientSpecs apply { "random" };

[_display] call afcm_sim_ui_fnc_mciCreator_populatePatientList;
