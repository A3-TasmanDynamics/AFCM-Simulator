/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the confirmation dialog's Yes button. Closes the dialog, then calls
 * whatever Code fnc_confirmDialog_open.sqf stashed (AFCM_SIM_UI_confirmYesCode) - the actual
 * destructive action itself lives in the caller, not here, so this stays generic.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Yes button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlYes"];

private _yesCode = missionNamespace getVariable ["AFCM_SIM_UI_confirmYesCode", {}];

closeDialog 0;

call _yesCode;

missionNamespace setVariable ["AFCM_SIM_UI_confirmMessage", nil];
missionNamespace setVariable ["AFCM_SIM_UI_confirmYesCode", nil];
