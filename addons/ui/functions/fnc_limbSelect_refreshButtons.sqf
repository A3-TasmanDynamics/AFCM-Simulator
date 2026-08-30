/*
 * Author: Tasman Dynamics
 * Recolors every limb button on RscDisplayAFCM_SIM_LimbSelect to reflect AFCM_SIM_UI_selectedLimbs
 * (real command `ctrlSetBackgroundColor`, sets a control's background at runtime - the standard
 * way to show a toggle-selected state, since Arma buttons have no built-in "pressed/stuck" visual)
 * and updates the Apply Trauma button's text/enabled state to match how many limbs are currently
 * toggled.
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

if (isNull _display) exitWith {};

disableSerialization;

private _limbIdcs = [
    ["head", 10], ["chest", 11], ["leftArm", 12],
    ["rightArm", 13], ["leftLeg", 14], ["rightLeg", 15]
];

// Same literal RGBA values as the AFCM_SIM_COLOR_BTN_BG/AFCM_SIM_COLOR_ACCENT_HOVER #defines in
// ui/config.cpp - those are preprocessor macros, only usable inside config.cpp itself, not real
// variables reachable from SQF, so the actual numbers are duplicated here. Keep both in sync if
// the brand palette ever changes.
private _colorUnselected = [0.12, 0.12, 0.135, 0.92];
private _colorSelected = [0.757, 0.153, 0.176, 0.85];

{
    _x params ["_limb", "_idc"];
    private _ctrl = _display displayCtrl _idc;
    private _isSelected = _limb in AFCM_SIM_UI_selectedLimbs;
    _ctrl ctrlSetBackgroundColor ([_colorUnselected, _colorSelected] select _isSelected);
} forEach _limbIdcs;

private _count = count AFCM_SIM_UI_selectedLimbs;
private _applyBtn = _display displayCtrl 19;
_applyBtn ctrlEnable (_count > 0);
_applyBtn ctrlSetText (
    if (_count == 0) then {
        "Select Limb(s) to Continue"
    } else {
        format ["Apply Trauma to %1 Selected Limb%2", _count, ["", "s"] select (_count != 1)]
    }
);
