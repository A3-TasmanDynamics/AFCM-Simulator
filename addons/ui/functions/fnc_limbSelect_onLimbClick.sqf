/*
 * Author: Tasman Dynamics
 * Button handler for the limb-selection dialog (RscDisplayAFCM_SIM_LimbSelect). Publishes
 * "limb.selected" on the UI event bus (DESIGN.md §5), closes the dialog, then opens the injury
 * editor for the same target unit (stashed by fnc_limbSelect_open.sqf) and this limb.
 *
 * Arguments:
 * 0: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1 (head / chest / leftArm / rightArm /
 *    leftLeg / rightLeg)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_limbId"];

diag_log text format ["[AFCM-Simulator][UI] Limb '%1' selected.", _limbId];

["limb.selected", [_limbId]] call afcm_sim_ui_fnc_publish;

closeDialog 0;

// Opening a new dialog synchronously in the same frame closeDialog ran in can silently fail (the
// engine is still tearing down the old display) - defer to next frame, same technique already used
// for dialog init elsewhere in this addon (CBA_fnc_execNextFrame).
private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
[{
    params ["_targetUnit", "_limbId"];
    [_targetUnit, _limbId] call afcm_sim_ui_fnc_injuryEditor_open;
}, [_targetUnit, _limbId]] call CBA_fnc_execNextFrame;
