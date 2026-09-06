/*
 * Author: Tasman Dynamics
 * Recolors the 6 limb navbar buttons on RscDisplayAFCM_SIM_InjuryAuthor to reflect which one is
 * currently active (AFCM_SIM_UI_activeLimb) and which already have something staged
 * (AFCM_SIM_UI_stagedInjuries, or a relevant nonzero AFCM_SIM_UI_stagedKatExtras slice) - 3 visual
 * states, not the old LimbSelect's 2 (unselected/selected), since this is single-active-limb
 * navigation rather than a multi-toggle. This is also what fnc_injuryAuthor_init.sqf's own
 * MouseExit handler calls to restore the correct color after a 4th, purely transient hover tint
 * (script-driven too, same file - see its own comment for why native hover/focus colors can't do
 * this correctly) - re-running this is always safe/idempotent, it just recomputes all 6 from
 * scratch regardless of why it was called.
 *
 * Literal RGBA values, not the AFCM_SIM_COLOR_* #defines (preprocessor-only, unreachable from
 * SQF) - same duplication fnc_limbSelect_refreshButtons.sqf already had. Keep in sync with
 * addons/ui/config.cpp if the brand palette ever changes, and with the hover tint
 * fnc_injuryAuthor_init.sqf sets directly ([0.757, 0.153, 0.176, 0.5] - deliberately between this
 * file's own _colorStaged 0.28 alpha and _colorActive 0.85, so it reads as distinct from both).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

disableSerialization;

// 25611 = IDD_AFCM_SIM_INJURYAUTHOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
private _display = findDisplay 25611;
if (isNull _display) exitWith {};

private _limbIdcs = [
    ["head", 10], ["chest", 11], ["leftArm", 12],
    ["rightArm", 13], ["leftLeg", 14], ["rightLeg", 15]
];

private _colorEmpty = [0.12, 0.12, 0.135, 0.92];
private _colorStaged = [0.757, 0.153, 0.176, 0.28];
private _colorActive = [0.757, 0.153, 0.176, 0.85];

private _activeLimb = missionNamespace getVariable ["AFCM_SIM_UI_activeLimb", ""];
private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];
private _katExtras = missionNamespace getVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
_katExtras params [["_fractures", [0, 0, 0, 0, 0, 0]], ["_pneumoType", 0], ["_airwayType", 0], ["_rhythm", 0]];

private _fractureLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];

{
    _x params ["_limb", "_idc"];
    private _ctrl = _display displayCtrl _idc;

    private _hasStaged = (_injuries findIf { (_x select 0) == _limb }) != -1;
    if !(_hasStaged) then {
        if (_limb in _fractureLimbs) then {
            private _limbIndex = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"] find _limb;
            _hasStaged = (_fractures param [_limbIndex, 0]) > 0;
        };
        if (_limb == "chest") then { _hasStaged = _hasStaged || {_pneumoType > 0} || {_rhythm > 0}; };
        if (_limb == "head") then { _hasStaged = _hasStaged || {_airwayType > 0}; };
    };

    private _color = _colorEmpty;
    if (_hasStaged) then { _color = _colorStaged; };
    if (_limb == _activeLimb) then { _color = _colorActive; };

    _ctrl ctrlSetBackgroundColor _color;
} forEach _limbIdcs;
