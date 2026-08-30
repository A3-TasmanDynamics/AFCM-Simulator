/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_PresetSave - just wires the Save button. Cancel is a plain
 * `action = "closeDialog 0;"` in config.cpp, same as several other Cancel/Close buttons in this
 * addon, so it doesn't need a handler here.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryEditor_init.sqf.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_PresetSave <DISPLAY>
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
    (_display displayCtrl 11) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_presetSave_onSave];
}, [_display]] call CBA_fnc_execNextFrame;
