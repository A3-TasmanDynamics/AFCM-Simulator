/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_ConfirmDialog. Sets the message text from
 * AFCM_SIM_UI_confirmMessage (fnc_confirmDialog_open.sqf) and wires the Yes button. No is a plain
 * `action = "closeDialog 0;"` in config.cpp, same as several other Cancel/No-style buttons in this
 * addon.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryEditor_init.sqf.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_ConfirmDialog <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display"];

[{
    disableSerialization;
    params ["_display"];

    private _message = missionNamespace getVariable ["AFCM_SIM_UI_confirmMessage", "Are you sure?"];
    (_display displayCtrl 10) ctrlSetText _message;

    (_display displayCtrl 11) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_confirmDialog_onYes];
}, [_display]] call CBA_fnc_execNextFrame;
