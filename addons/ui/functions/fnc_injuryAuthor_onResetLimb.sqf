/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's Reset Limb button. Local-only: removes the
 * active limb's entry from AFCM_SIM_UI_stagedInjuries and zeroes its AFCM_SIM_UI_stagedKatExtras
 * slice (if applicable), then refreshes the form/navbar to reflect the clear. Never touches a live
 * unit - same purely-local contract the old fnc_injuryEditor_onReset.sqf had, just scoped to
 * whichever ONE limb is active in the navbar now instead of the whole multi-select.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Reset Limb button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlReset"];

private _limb = missionNamespace getVariable ["AFCM_SIM_UI_activeLimb", ""];
if (_limb == "") exitWith {};

private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];
_injuries = _injuries select { (_x select 0) != _limb };
missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", _injuries];

private _katExtras = missionNamespace getVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
_katExtras params ["_fractures", "_pneumoType", "_airwayType", "_rhythm"];

private _fractureLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];
if (_limb in _fractureLimbs) then {
    private _limbIndex = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"] find _limb;
    _fractures set [_limbIndex, 0];
};
if (_limb == "chest") then { _pneumoType = 0; _rhythm = 0; };
if (_limb == "head") then { _airwayType = 0; };

missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", [_fractures, _pneumoType, _airwayType, _rhythm]];

call afcm_sim_ui_fnc_injuryAuthor_refreshActiveLimbForm;
call afcm_sim_ui_fnc_injuryAuthor_refreshNavbar;
