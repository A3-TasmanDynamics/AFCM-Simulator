/*
 * Author: Tasman Dynamics
 * Button handler for the limb-selection dialog (RscDisplayAFCM_SIM_LimbSelect). Publishes
 * "limb.selected" on the UI event bus (DESIGN.md §5), closes the dialog, then opens the injury
 * editor for the same target unit (stashed by fnc_limbSelect_open.sqf) and this limb.
 *
 * Arguments:
 * 0: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1 (head / neck / chest / abdomen /
 *    pelvis / leftUpperArm / leftForearm / rightUpperArm / rightForearm / leftThigh / leftShin /
 *    rightThigh / rightShin)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_limbId"];

["limb.selected", [_limbId]] call afcm_sim_ui_fnc_publish;

closeDialog 0;

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
[_targetUnit, _limbId] call afcm_sim_ui_fnc_injuryEditor_open;
