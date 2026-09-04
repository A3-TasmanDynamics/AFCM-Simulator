/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Preset Library's Apply button (RscDisplayAFCM_SIM_PresetLibrary).
 * Looks up the selected preset (afcm_sim_scenario_fnc_findPreset) and, depending on mode, either
 * loads it into the Injury Author dialog's staging form or remoteExecs its injuries (plus any KAT
 * extras/cardiac state - the Preset shape's optional 7th element, fnc_exportPatientState.sqf) to
 * the server (afcm_sim_scenario_fnc_serverApplyPreset) - never applies locally except via that
 * server round trip (DESIGN.md §6).
 *
 * Three modes, checked in this order:
 *  - Staging: AFCM_SIM_UI_targetStaging (bool) - set by the Injury Author dialog's own Load Preset
 *    button (fnc_injuryAuthor_onLoadPreset.sqf). Loads the preset straight into that dialog's
 *    staged arrays (fnc_injuryAuthor_loadPresetArrays.sqf) instead of touching any live unit -
 *    checked first since it's a real, separate destination, not a live-unit apply at all.
 *  - Batch (MCI): AFCM_SIM_UI_targetUnits (plural, non-empty) - set by the "Assign MCI Preset"
 *    action on a freshly-spawned MCI batch (fnc_addMciPresetAction.sqf). Applies the same preset
 *    to every unit in the array, one serverApplyPreset request per unit.
 *  - Single: AFCM_SIM_UI_targetUnit (singular) - the normal flow from the Injury Author dialog's
 *    Load Preset button in edit mode isn't reached here (that's staging, above) - this is presets
 *    opened some other way with a single live target already set.
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

private _injuries = _preset select 4;
// katExtras - the Preset shape's optional 7th element (fnc_exportPatientState.sqf), absent on
// every built-in/older preset.
private _katExtras = if (count _preset >= 7) then { _preset select 6 } else { [] };

if (missionNamespace getVariable ["AFCM_SIM_UI_targetStaging", false]) exitWith {
    missionNamespace setVariable ["AFCM_SIM_UI_targetStaging", false];
    diag_log text format ["[AFCM-Simulator][UI] Loading preset '%1' into Injury Author staging.", _preset select 1];
    [_injuries, _katExtras] call afcm_sim_ui_fnc_injuryAuthor_loadPresetArrays;
    closeDialog 0;
};

private _targetUnits = missionNamespace getVariable ["AFCM_SIM_UI_targetUnits", []];

if (_targetUnits isNotEqualTo []) then {
    diag_log text format ["[AFCM-Simulator][UI] Applying preset '%1' to MCI batch of %2 unit(s).", _preset select 1, count _targetUnits];
    { [_x, _injuries, _katExtras] remoteExec ["afcm_sim_scenario_fnc_serverApplyPreset", 2]; } forEach _targetUnits;
    missionNamespace setVariable ["AFCM_SIM_UI_targetUnits", []];
} else {
    private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
    if (isNull _targetUnit) exitWith {
        diag_log text "[AFCM-Simulator][UI] Preset Apply aborted - no target unit(s) set.";
    };
    diag_log text format ["[AFCM-Simulator][UI] Applying preset '%1' to %2.", _preset select 1, _targetUnit];
    [_targetUnit, _injuries, _katExtras] remoteExec ["afcm_sim_scenario_fnc_serverApplyPreset", 2];
};

closeDialog 0;
