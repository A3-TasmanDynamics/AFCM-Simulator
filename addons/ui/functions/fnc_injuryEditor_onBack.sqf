/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the injury editor's Back button (RscDisplayAFCM_SIM_InjuryEditor,
 * formerly "Cancel" - a plain `closeDialog 0` dropped the instructor out of the whole flow with no
 * way back to picking a different limb without re-triggering the "Edit Injuries" scroll action
 * from scratch). Closes this dialog and reopens the limb-select ("main") screen
 * (afcm_sim_ui_fnc_limbSelect_open) for the same target unit (AFCM_SIM_UI_targetUnit, already
 * stashed - never applies anything, so there's nothing else to carry over).
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_limbSelect_onLimbClick.sqf - opening a
 * dialog synchronously in the same frame a prior closeDialog ran in can silently fail.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Back button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlBack"];

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];

closeDialog 0;

[{
    params ["_targetUnit"];
    if (isNull _targetUnit) exitWith {};
    [_targetUnit] call afcm_sim_ui_fnc_limbSelect_open;
}, [_targetUnit]] call CBA_fnc_execNextFrame;
