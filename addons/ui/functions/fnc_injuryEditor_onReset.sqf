/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the injury editor's Reset button (RscDisplayAFCM_SIM_InjuryEditor).
 * Wipes everything done to the patient so far via afcm_sim_scenario_fnc_serverReset (same
 * request -> server pattern as Apply, DESIGN.md §6) and re-locks it back to the unconscious
 * baseline. Keeps the dialog open afterward (unlike Apply/Cancel) - the live status readout
 * (fnc_injuryEditor_refreshState.sqf, already polling every 0.5s) will show the clean state within
 * a moment, and the instructor can immediately pick a fresh injury to start the exercise over.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Reset button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlReset"];

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];

diag_log text format ["[AFCM-Simulator][UI] Reset clicked - target %1.", _targetUnit];

if (isNull _targetUnit) exitWith {
    diag_log text "[AFCM-Simulator][UI] Reset aborted - AFCM_SIM_UI_targetUnit is objNull.";
};

[_targetUnit] remoteExec ["afcm_sim_scenario_fnc_serverReset", 2];
