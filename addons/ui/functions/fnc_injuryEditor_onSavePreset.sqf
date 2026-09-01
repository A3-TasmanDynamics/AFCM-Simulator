/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the injury editor's Save as Preset button
 * (RscDisplayAFCM_SIM_InjuryEditor). Reads the currently-configured wound (same wound-type/
 * severity/bleeding fields Apply reads, fnc_injuryEditor_onApply.sqf) and stashes it as a
 * preset-in-progress with one entry per selected limb (AFCM_SIM_UI_targetLimbs — the same wound
 * applied to every one of them, same as Apply does), then opens RscDisplayAFCM_SIM_PresetSave on
 * top of this dialog to name and save it.
 *
 * Deliberately does NOT include Fracture/Pneumothorax/Airway even if visible/set - the Preset
 * schema (DESIGN.md §4.3) only holds real Injury-shaped entries ([limb, woundType, severity,
 * bleeding]), and that KAT-only state has no equivalent there at all (INJURY_CODES.md §6, same
 * reason they're applied via a separate direct call rather than the generic dispatch).
 *
 * Doesn't close this dialog - Save as Preset never touches the patient, so there's no reason to
 * lose the form; the two dialogs simply stack (RscDisplayAFCM_SIM_PresetSave opens on top).
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Save as Preset button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlSave"];

private _display = ctrlParent _ctrlSave;

private _woundTypes = ["gunshot", "shrapnel", "blast"];
private _severities = [0.25, 0.5, 0.75, 1.0];

private _woundType = _woundTypes param [lbCurSel (_display displayCtrl 11), "gunshot"];
private _severity = _severities param [lbCurSel (_display displayCtrl 12), 0.5];
private _bleeding = cbChecked (_display displayCtrl 13);
private _limbs = missionNamespace getVariable ["AFCM_SIM_UI_targetLimbs", ["chest"]];

private _injuries = _limbs apply { [_x, _woundType, _severity, _bleeding] };
missionNamespace setVariable ["AFCM_SIM_UI_pendingPresetInjuries", _injuries];

[{
    createDialog "RscDisplayAFCM_SIM_PresetSave";
}, []] call CBA_fnc_execNextFrame;
