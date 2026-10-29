/*
 * Author: Tasman Dynamics
 * Adds the "Mark as Treated" scroll-wheel action to a patient unit - the manual half of the Medical
 * Tent's "Both" treated-detection mode (afcm_sim_scenario_fnc_isPatientTreated auto-detects via
 * live medical state OR this manual flag, whichever comes first). Run via remoteExec (target 0 =
 * everyone, JIP-persisted) from afcm_sim_spawner_fnc_spawnPatient, same reasoning as
 * fnc_addInjuryEditorAction.sqf - addAction is inherently local to whichever machine calls it.
 *
 * The action itself just remoteExecs the server-authoritative setter
 * (afcm_sim_scenario_fnc_serverMarkTreated, target 2 = server only) - never sets the flag locally,
 * same server-authority pattern every other AFCM state change already follows (DESIGN.md §6).
 *
 * Condition gated behind afcm_sim_requireInjuryEditPermission the same way
 * fnc_addInjuryEditorAction.sqf's own Edit Injuries condition is, on request ("must have permission
 * to see all 3 options") - a player who can edit injuries should see the full set of patient-state
 * actions, not just that one. Still unconditionally "true" (unrestricted) when the setting is off,
 * same unchanged-default-behaviour reasoning that condition's own comment documents.
 *
 * Arguments:
 * 0: Patient unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit"];

if (isNull _unit) exitWith {};

private _condition = "!afcm_sim_requireInjuryEditPermission || {player getVariable ['AFCM_SIM_canEditInjuries', false]}";

_unit addAction [
    "<t color='#c1272d'>AFCM: Mark as Treated</t>",
    {
        params ["_target"];
        [_target] remoteExec ["afcm_sim_scenario_fnc_serverMarkTreated", 2];
    },
    [],
    1.3,
    true,
    true,
    "",
    _condition,
    5
];
