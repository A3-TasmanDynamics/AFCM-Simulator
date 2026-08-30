/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Creator's "Assign Selected Preset to Selected Patient" button.
 * Writes the currently-selected Preset list row's real Preset id (or "random") into
 * AFCM_SIM_UI_mciPatientSpecs at the currently-selected Patient list row's index, then refreshes
 * the Patient list to show the new label.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Assign button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlAssign"];

private _display = ctrlParent _ctrlAssign;
private _patientIdx = lbCurSel (_display displayCtrl 12);
private _presetIdx = lbCurSel (_display displayCtrl 13);

if (_patientIdx == -1 || {_presetIdx == -1}) exitWith {};

private _specId = (_display displayCtrl 13) lbData _presetIdx;
AFCM_SIM_UI_mciPatientSpecs set [_patientIdx, _specId];

[_display] call afcm_sim_ui_fnc_mciCreator_populatePatientList;
