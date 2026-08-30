/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_MapPicker - wires the map's real MouseButtonDown event
 * (real control event, `_this = [_control, _button, _x, _y, _shift, _ctrl, _alt]`) and the Confirm
 * button. Cancel is a plain `action = "closeDialog 0;"` in config.cpp.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryEditor_init.sqf.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_MapPicker <DISPLAY>
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
    (_display displayCtrl 10) ctrlAddEventHandler ["MouseButtonDown", afcm_sim_ui_fnc_mapPicker_onClick];
    (_display displayCtrl 11) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mapPicker_onConfirm];
}, [_display]] call CBA_fnc_execNextFrame;
