/*
 * Author: Tasman Dynamics
 * Shared "paint the consciousness checkbox" logic - sets the real checked state as a variable on
 * the control itself (`AFCM_SIM_unconsciousChecked`, read back by fnc_injuryAuthor_onApply.sqf and
 * fnc_injuryAuthor_onToggleConsciousness.sqf) and recolors its background to match this UI's own
 * existing "filled danger-red = critical state" language (AFCM_SIM_COLOR_DANGER_BG/
 * AFCM_SIM_COLOR_DANGER_HOVER, config.cpp - the same colors Reset Patient already uses) when
 * checked, or back to the normal button background when not. Extracted out of
 * fnc_injuryAuthor_init.sqf's prefill and fnc_injuryAuthor_onToggleConsciousness.sqf's click
 * handler so both paint it identically rather than duplicating the color constants.
 *
 * Arguments:
 * 0: Consciousness checkbox <CONTROL>
 * 1: Checked <BOOL> - true = unconscious
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrl", "_checked"];

_ctrl setVariable ["AFCM_SIM_unconsciousChecked", _checked];

if (_checked) then {
    _ctrl ctrlSetBackgroundColor [0.42, 0.1, 0.09, 0.9];
    _ctrl ctrlSetTextColor [0.949, 0.937, 0.902, 1];
} else {
    _ctrl ctrlSetBackgroundColor [0.12, 0.12, 0.135, 0.92];
    _ctrl ctrlSetTextColor [0.75, 0.72, 0.68, 1];
};
