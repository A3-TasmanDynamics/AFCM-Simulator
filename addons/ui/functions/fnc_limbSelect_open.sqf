/*
 * Author: Tasman Dynamics
 * Opens the limb-selection dialog (DESIGN.md §5 "Selectable Body Limbs"). Limb buttons toggle
 * on/off (fnc_limbSelect_onLimbToggle.sqf) rather than navigating away immediately - one or more
 * can be selected before continuing. Clicking "Apply Trauma to Selected Limb(s)"
 * (fnc_limbSelect_onApplyTrauma.sqf) publishes "limb.selected" on the UI event bus, closes this
 * dialog, then opens the injury editor (fnc_injuryEditor_open.sqf) for the same target unit and
 * the whole selection at once — this dialog never calls afcm_sim_scenario directly (DESIGN.md §3),
 * only afcm_sim_ui's own next dialog.
 *
 * _targetUnit is stashed in a plain (client-local, unsynced) missionNamespace variable rather than
 * threaded through dialog params, since RscDisplay dialogs don't take arguments — every downstream
 * step in this flow (onLimbClick, the injury editor) reads it back from there.
 *
 * Arguments:
 * 0: Target unit <OBJECT> - the patient this injury editor session is for
 *
 * Return Value:
 * Bool - result of createDialog
 *
 * Public: Yes
*/

params ["_targetUnit"];

missionNamespace setVariable ["AFCM_SIM_UI_targetUnit", _targetUnit];

private _result = createDialog "RscDisplayAFCM_SIM_LimbSelect";
diag_log text format ["[AFCM-Simulator][UI] limbSelect_open for %1 - createDialog result: %2.", _targetUnit, _result];
_result
