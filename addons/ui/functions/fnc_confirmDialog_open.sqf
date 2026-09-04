/*
 * Author: Tasman Dynamics
 * Opens the generic Yes/No confirmation dialog (RscDisplayAFCM_SIM_ConfirmDialog) - not specific
 * to sessions, any future destructive action in this addon can reuse it. Stashes the message and
 * the Code to run if the operator clicks Yes in plain (client-local, unsynced) missionNamespace
 * variables, same reasoning as fnc_injuryAuthor_open.sqf - the dialog's own onLoad
 * (fnc_confirmDialog_init.sqf) and Yes handler (fnc_confirmDialog_onYes.sqf) read them back.
 *
 * Arguments:
 * 0: Message <STRING> - shown in the dialog body
 * 1: Yes code <CODE> - called with no arguments if the operator confirms
 *
 * Return Value:
 * Bool - result of createDialog
 *
 * Public: Yes
*/

params ["_message", "_yesCode"];

missionNamespace setVariable ["AFCM_SIM_UI_confirmMessage", _message];
missionNamespace setVariable ["AFCM_SIM_UI_confirmYesCode", _yesCode];

createDialog "RscDisplayAFCM_SIM_ConfirmDialog"
