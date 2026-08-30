/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_MciPresetSave - just wires the Save button. Cancel is a
 * plain `action = "closeDialog 0;"` in config.cpp.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryEditor_init.sqf.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_MciPresetSave <DISPLAY>
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
    (_display displayCtrl 11) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciPresetSave_onSave];
}, [_display]] call CBA_fnc_execNextFrame;
