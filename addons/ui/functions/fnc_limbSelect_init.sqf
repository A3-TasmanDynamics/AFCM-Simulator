/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_LimbSelect. Resets AFCM_SIM_UI_selectedLimbs to empty
 * every time this dialog opens (including reopening via Back from the injury editor, or after a
 * Reset Patient click that leaves this dialog open) - a fresh, empty toggle selection is always
 * the right starting point, never a stale one from whatever was selected last.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryEditor_init.sqf - ensures
 * controls exist before being touched.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_LimbSelect <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display"];

AFCM_SIM_UI_selectedLimbs = [];

[{
    disableSerialization;
    params ["_display"];
    [_display] call afcm_sim_ui_fnc_limbSelect_refreshButtons;
}, [_display]] call CBA_fnc_execNextFrame;
