/*
 * Author: Tasman Dynamics
 * Opens the injury editor dialog (DESIGN.md §5 "Selectable Injuries") for one or more limbs on one
 * target unit at once — wound type, severity, bleed toggle, applied identically to every limb in
 * the selection on Apply (fnc_injuryEditor_onApply.sqf). This is the "manual" source of the "one
 * application pipeline, three sources: manual, preset, randomized" framing (DESIGN.md §5); Apply
 * routes through afcm_sim_scenario_fnc_serverApplyInjury, the same afcm_sim_fnc_backend_applyInjury
 * dispatch the randomizer already uses - once per limb.
 *
 * _targetUnit/_limbs are stashed in plain (client-local, unsynced) missionNamespace variables
 * rather than threaded through dialog params, same reasoning as fnc_limbSelect_open.sqf — the
 * dialog's own onLoad (fnc_injuryEditor_init.sqf) and Apply handler
 * (fnc_injuryEditor_onApply.sqf) read them back.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbIds <ARRAY of STRING> - one or more, see DESIGN.md §4.1 / INJURY_CODES.md §1
 *
 * Return Value:
 * Bool - result of createDialog
 *
 * Public: Yes
*/

params ["_targetUnit", "_limbs"];

if (isNull _targetUnit || {_limbs isEqualTo []}) exitWith { false };

missionNamespace setVariable ["AFCM_SIM_UI_targetUnit", _targetUnit];
missionNamespace setVariable ["AFCM_SIM_UI_targetLimbs", _limbs];

private _result = createDialog "RscDisplayAFCM_SIM_InjuryEditor";
diag_log text format ["[AFCM-Simulator][UI] injuryEditor_open for %1/%2 - createDialog result: %3.", _targetUnit, _limbs, _result];
_result
