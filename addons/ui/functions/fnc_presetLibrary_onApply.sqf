/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Preset Library's Apply button (RscDisplayAFCM_SIM_PresetLibrary).
 * Looks up the selected preset (afcm_sim_scenario_fnc_findPreset) and remoteExecs every one of its
 * injuries to the server in one request (afcm_sim_scenario_fnc_serverApplyPreset) - never applies
 * locally (DESIGN.md §6, same pattern as the injury editor's own Apply).
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Apply button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlApply"];

private _display = ctrlParent _ctrlApply;
private _index = lbCurSel (_display displayCtrl 10);
if (_index == -1) exitWith {};

private _id = (_display displayCtrl 10) lbData _index;
private _preset = [_id] call afcm_sim_scenario_fnc_findPreset;
if (_preset isEqualTo []) exitWith {};

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
if (isNull _targetUnit) exitWith {
    diag_log text "[AFCM-Simulator][UI] Preset Apply aborted - AFCM_SIM_UI_targetUnit is objNull.";
};

diag_log text format ["[AFCM-Simulator][UI] Applying preset '%1' to %2.", _preset select 1, _targetUnit];

[_targetUnit, _preset select 4] remoteExec ["afcm_sim_scenario_fnc_serverApplyPreset", 2];

closeDialog 0;
