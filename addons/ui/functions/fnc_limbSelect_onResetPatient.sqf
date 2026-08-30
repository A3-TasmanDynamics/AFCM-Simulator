/*
 * Author: Tasman Dynamics
 * Button handler for the limb-selection dialog's Reset Patient button
 * (RscDisplayAFCM_SIM_LimbSelect). Wipes everything done to the patient so far
 * (afcm_sim_scenario_fnc_serverReset — fullHeal + re-lock unconscious, same request -> server
 * pattern as Apply, DESIGN.md §6) and re-locks it back to the unconscious baseline.
 *
 * This is the full-unit reset, moved here from the injury editor (which now has its own much
 * lighter, purely-local "Reset Limb" that only clears the form — fnc_injuryEditor_onReset.sqf).
 * A whole-patient wipe belongs on the main/limb-select screen, not buried inside a single-limb
 * editor where "Reset Patient" read as scoped to just that limb.
 *
 * Doesn't close the dialog afterward - an instructor may want to immediately pick a limb and start
 * treating again right after wiping the patient.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];

diag_log text format ["[AFCM-Simulator][UI] Reset Patient clicked - target %1.", _targetUnit];

if (isNull _targetUnit) exitWith {
    diag_log text "[AFCM-Simulator][UI] Reset Patient aborted - AFCM_SIM_UI_targetUnit is objNull.";
};

[_targetUnit] remoteExec ["afcm_sim_scenario_fnc_serverReset", 2];
