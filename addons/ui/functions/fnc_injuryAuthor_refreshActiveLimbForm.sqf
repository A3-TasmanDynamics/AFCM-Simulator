/*
 * Author: Tasman Dynamics
 * Repopulates the injury-configuration form (RscDisplayAFCM_SIM_InjuryAuthor) from whatever's
 * already staged for AFCM_SIM_UI_activeLimb, and re-derives which of Fracture/Pneumothorax/
 * Airway/CardiacState are relevant to it - the exact same arm-leg/chest/head rules the old
 * InjuryEditor used (fnc_injuryEditor_init.sqf), just evaluated for one active limb instead of a
 * multi-select `findIf`. Deliberately does NOT commit the screen first (that's
 * fnc_injuryAuthor_commitActiveLimbForm.sqf's job) - callers that just replaced the staged arrays
 * wholesale (Import/Load Preset/Random Damage/Clear All/a fresh Reset Patient reload) need the
 * on-screen form to reflect the NEW data, not have their own fresh values immediately overwritten
 * by committing the stale pre-replace screen state.
 *
 * Real, confirmed bug fixed here: `_woundTypes find _woundType max 0` (no parens) is NOT
 * `(_woundTypes find _woundType) max 0` - SQF's real binary-operator precedence puts `max` above
 * `find` (same tier as `+`/`-`/`min`), so it parsed as `_woundTypes find (_woundType max 0)`,
 * evaluating `_woundType max 0` (a STRING `max` a NUMBER) first - confirmed from a real RPT crash
 * (`Error max: Type String, expected Number, Not a Number`). Explicit parens now force the
 * intended grouping.
 *
 * Severity's own index 0 is now "None" (-1, afcm_sim_scenario_fnc_buildInjury's own "not specified"
 * sentinel) - a totally unconfigured limb now defaults every combo (WoundType/Severity/Bleeding) to
 * its own index 0/None consistently, rather than Severity alone defaulting to "Moderate" while the
 * other two showed "None". `_severityIdx == -1` below is `findIf`'s own "not found" sentinel (an
 * INDEX), not the searched -1 VALUE, so there's no collision with the new None entry actually being
 * -1 - a real staged -1 severity is found at index 0 like any other value.
 *
 * Bleeding's None/Small/Medium/Large options match 4 exact, canonical bleedRate numbers
 * (fnc_injuryAuthor_commitActiveLimbForm.sqf), so a limb staged BY THIS DIALOG always finds an exact
 * `_bleedIdx` match below. A bleedRate that DOESN'T exactly match one of those 4 - a continuous
 * value from afcm_sim_scenario_fnc_randomizeInjuries, an imported/older preset, or anything crafted
 * outside this dialog - now buckets by the same real ACE thresholds
 * fnc_medical_applyAceStyleInjuryLocal.sqf itself uses (<0.15 small, 0.15-0.3 medium, >=0.3 large)
 * rather than crudely guessing "Small" for any non-exact match, so the combo always shows the ACE
 * wound size that value will actually produce.
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

private _limb = missionNamespace getVariable ["AFCM_SIM_UI_activeLimb", "chest"];
private _backend = call afcm_sim_fnc_backend_getActive;

private _limbNames = createHashMapFromArray [
    ["head", "Head"], ["chest", "Chest"],
    ["leftArm", "Left Arm"], ["rightArm", "Right Arm"],
    ["leftLeg", "Left Leg"], ["rightLeg", "Right Leg"]
];
(_display displayCtrl 16) ctrlSetText format ["Editing — %1", _limbNames getOrDefault [_limb, _limb]];

private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];
private _staged = _injuries select { (_x select 0) == _limb };
private _woundTypes = ["", "gunshot", "shrapnel", "blast"];
private _severities = [-1, 0.25, 0.5, 0.75, 1.0];
private _bleedingLevels = [[false, 0], [true, 0.1], [true, 0.2], [true, 0.4]];

if (_staged isEqualTo []) then {
    (_display displayCtrl 20) lbSetCurSel 0;
    (_display displayCtrl 21) lbSetCurSel 0;
    (_display displayCtrl 22) lbSetCurSel 0;
} else {
    (_staged select 0) params ["", "_woundType", "_severity", "_bleeding", ["_bleedRate", -1]];
    (_display displayCtrl 20) lbSetCurSel ((_woundTypes find _woundType) max 0);
    private _severityIdx = _severities findIf { abs (_x - _severity) < 0.001 };
    (_display displayCtrl 21) lbSetCurSel ([_severityIdx, 0] select (_severityIdx == -1));
    private _bleedIdx = _bleedingLevels findIf { (_x select 0) isEqualTo _bleeding && {abs ((_x select 1) - (_bleedRate max 0)) < 0.001} };
    if (_bleedIdx == -1) then {
        // No exact match - bucket by the same real ACE addWound thresholds
        // fnc_medical_applyAceStyleInjuryLocal.sqf uses, not a guess.
        _bleedIdx = if (_bleeding) then { [1, 2] select (_bleedRate >= 0.15) } else { 0 };
        if (_bleeding && {_bleedRate >= 0.3}) then { _bleedIdx = 3; };
    };
    (_display displayCtrl 22) lbSetCurSel _bleedIdx;
};

private _katExtras = missionNamespace getVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
_katExtras params [["_fractures", [0, 0, 0, 0, 0, 0]], ["_pneumoType", 0], ["_airwayType", 0], ["_rhythm", 0]];

private _fractureLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];
private _showFracture = (_backend == "kat") && {_limb in _fractureLimbs};
private _showPneumo = (_backend == "kat") && {_limb == "chest"};
private _showAirway = (_backend == "kat") && {_limb == "head"};
private _showCardiac = (_backend in ["ace", "kat"]) && {_limb == "chest"};

{ (_display displayCtrl _x) ctrlShow _showFracture; } forEach [23, 24];
{ (_display displayCtrl _x) ctrlShow _showPneumo; } forEach [25, 26];
{ (_display displayCtrl _x) ctrlShow _showAirway; } forEach [27, 28];
{ (_display displayCtrl _x) ctrlShow _showCardiac; } forEach [29, 30];

if (_showFracture) then {
    private _limbIndex = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"] find _limb;
    (_display displayCtrl 24) lbSetCurSel (_fractures param [_limbIndex, 0]);
};
if (_showPneumo) then { (_display displayCtrl 26) lbSetCurSel _pneumoType; };
if (_showAirway) then { (_display displayCtrl 28) lbSetCurSel _airwayType; };
if (_showCardiac) then { (_display displayCtrl 30) lbSetCurSel (_rhythm min ((lbSize (_display displayCtrl 30)) - 1)); };
