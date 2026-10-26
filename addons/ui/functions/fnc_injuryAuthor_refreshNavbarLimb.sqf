/*
 * Author: Tasman Dynamics
 * Recolors ONE limb navbar entry (Nav*, AFCM_SIM_RscTextNavBg) on RscDisplayAFCM_SIM_InjuryAuthor to
 * its real (non-hover) color - empty/staged/active, the same 3-state logic
 * fnc_injuryAuthor_refreshNavbar.sqf uses for all 6, factored out here so a single limb can be
 * restored without touching the other 5.
 *
 * Real, confirmed bug fixed by existing: the navbar's own MouseExit handler
 * (fnc_injuryAuthor_init.sqf) used to call the full fnc_injuryAuthor_refreshNavbar.sqf - fine on its
 * own, but the 6 Nav*Hit hover regions are stacked edge-to-edge (addons/ui/config.cpp), so moving the
 * mouse directly from one limb's row to an adjacent one fires the NEW limb's MouseEnter (tinting it)
 * before the OLD limb's MouseExit fires. That MouseExit then repainted all 6 controls from scratch,
 * which correctly restored the old limb's color but also wiped the new limb's just-applied hover tint
 * a frame later - reported directly: nav buttons "highlighting when not actually [hovered]" and
 * staged-looking colors on limbs that aren't actually staged. Scoping MouseExit to repaint only its
 * own limb (this function) means hovering away from one limb can never touch a DIFFERENT limb's own
 * in-progress hover tint.
 *
 * Arguments:
 * 0: LimbId <STRING>
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_limbId"];

disableSerialization;

// 25611 = IDD_AFCM_SIM_INJURYAUTHOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
private _display = findDisplay 25611;
if (isNull _display) exitWith {};

private _limbIdcMap = createHashMapFromArray [
    ["head", 10], ["chest", 11], ["leftArm", 12],
    ["rightArm", 13], ["leftLeg", 14], ["rightLeg", 15]
];
private _idc = _limbIdcMap getOrDefault [_limbId, -1];
if (_idc == -1) exitWith {};

// Same literal RGBA values fnc_injuryAuthor_refreshNavbar.sqf uses - keep both in sync if the brand
// palette ever changes (not the AFCM_SIM_COLOR_* #defines, preprocessor-only, unreachable from SQF).
private _colorEmpty = [0.12, 0.12, 0.135, 0.92];
private _colorStaged = [0.757, 0.153, 0.176, 0.28];
private _colorActive = [0.42, 0.08, 0.09, 0.95];

private _activeLimb = missionNamespace getVariable ["AFCM_SIM_UI_activeLimb", ""];
private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];
private _katExtras = missionNamespace getVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
_katExtras params [["_fractures", [0, 0, 0, 0, 0, 0]], ["_pneumoType", 0], ["_airwayType", 0], ["_rhythm", 0]];

private _fractureLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];

private _hasStaged = (_injuries findIf { (_x select 0) == _limbId }) != -1;
if !(_hasStaged) then {
    if (_limbId in _fractureLimbs) then {
        private _limbIndex = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"] find _limbId;
        _hasStaged = (_fractures param [_limbIndex, 0]) > 0;
    };
    if (_limbId == "chest") then { _hasStaged = _hasStaged || {_pneumoType > 0} || {_rhythm > 0}; };
    if (_limbId == "head") then { _hasStaged = _hasStaged || {_airwayType > 0}; };
};

private _color = _colorEmpty;
if (_hasStaged) then { _color = _colorStaged; };
if (_limbId == _activeLimb) then { _color = _colorActive; };

(_display displayCtrl _idc) ctrlSetBackgroundColor _color;
