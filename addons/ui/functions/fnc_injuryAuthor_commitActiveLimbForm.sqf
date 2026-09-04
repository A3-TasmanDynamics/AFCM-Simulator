/*
 * Author: Tasman Dynamics
 * Flushes whatever's currently on screen for the active limb (RscDisplayAFCM_SIM_InjuryAuthor) into
 * the staged arrays (AFCM_SIM_UI_stagedInjuries/stagedKatExtras) - shared by
 * fnc_injuryAuthor_setActiveLimb.sqf (before switching to a different limb),
 * fnc_injuryAuthor_onApply.sqf, fnc_injuryAuthor_onExport.sqf, and
 * fnc_injuryAuthor_onSavePreset.sqf, all of which need "commit the screen" before reading the
 * staged arrays.
 *
 * WoundType index 0 is "None" - a UI-only sentinel (INJURY_CODES.md has no "none" woundType), so
 * that case removes the limb's entry from AFCM_SIM_UI_stagedInjuries entirely rather than ever
 * writing "none" into a tuple that could reach afcm_sim_scenario_fnc_buildInjury.
 *
 * Bleeding is a 5-option severity combo (None/Light/Medium/Heavy/Severe), each option a real
 * [bleeding<BOOL>, bleedRate<NUMBER>] pair read directly by index - see
 * fnc_injuryAuthor_init.sqf's own comment for where those 4 non-None rate values come from.
 *
 * Fracture/Pneumothorax/Airway/CardiacState combos are populated in index-order-equals-value order
 * (fnc_injuryAuthor_init.sqf, same convention the old InjuryEditor used), so `lbCurSel` is read
 * directly as the value with no separate mapping array needed - only read when the row is actually
 * `ctrlShown` (same per-limb gating fnc_injuryAuthor_setActiveLimb.sqf just set), so a hidden row's
 * stale/default selection never overwrites an unrelated staged value.
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

private _limb = missionNamespace getVariable ["AFCM_SIM_UI_activeLimb", ""];
if (_limb == "") exitWith {};

private _woundTypes = ["", "gunshot", "shrapnel", "blast"];
private _severities = [0.25, 0.5, 0.75, 1.0];
private _bleedingLevels = [[false, 0], [true, 0.1], [true, 0.2], [true, 0.35], [true, 0.5]];

private _woundType = _woundTypes param [lbCurSel (_display displayCtrl 20), ""];
private _severity = _severities param [lbCurSel (_display displayCtrl 21), 0.5];
private _bleedPair = _bleedingLevels param [lbCurSel (_display displayCtrl 22), [false, 0]];
_bleedPair params ["_bleeding", "_bleedRate"];

private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];
_injuries = _injuries select { (_x select 0) != _limb };
if (_woundType != "") then {
    _injuries pushBack [_limb, _woundType, _severity, _bleeding, _bleedRate];
};
missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", _injuries];

private _katExtras = missionNamespace getVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
_katExtras params ["_fractures", "_pneumoType", "_airwayType", "_rhythm"];

private _fractureLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];
if (_limb in _fractureLimbs && {ctrlShown (_display displayCtrl 24)}) then {
    private _limbIndex = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"] find _limb;
    _fractures set [_limbIndex, lbCurSel (_display displayCtrl 24)];
};
if (_limb == "chest") then {
    if (ctrlShown (_display displayCtrl 26)) then { _pneumoType = lbCurSel (_display displayCtrl 26); };
    if (ctrlShown (_display displayCtrl 30)) then { _rhythm = lbCurSel (_display displayCtrl 30); };
};
if (_limb == "head" && {ctrlShown (_display displayCtrl 28)}) then {
    _airwayType = lbCurSel (_display displayCtrl 28);
};

missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", [_fractures, _pneumoType, _airwayType, _rhythm]];
