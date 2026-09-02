/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the confirmation dialog's Yes button. Closes the dialog, then calls
 * whatever Code fnc_confirmDialog_open.sqf stashed (AFCM_SIM_UI_confirmYesCode) - the actual
 * destructive action itself lives in the caller, not here, so this stays generic.
 *
 * Real, confirmed bug fixed here: the missionNamespace vars used to be cleared *after* calling
 * _yesCode, not before. Since this dialog is deliberately generic/reusable for any future
 * destructive action (fnc_confirmDialog_open.sqf's own docstring), a Yes-handler that itself opens
 * a second confirm dialog (a natural "are you REALLY sure" chain) would have its own freshly-stashed
 * message/code wiped by this handler's own post-call cleanup, 0 frames after being set - the nested
 * dialog would show the default "Are you sure?" text and its own Yes button would call the default
 * no-op {}. Reading _yesCode into a local first, then clearing before calling it, means a chained
 * confirm dialog's own stash survives.
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

missionNamespace setVariable ["AFCM_SIM_UI_confirmMessage", nil];
missionNamespace setVariable ["AFCM_SIM_UI_confirmYesCode", nil];

call _yesCode;
