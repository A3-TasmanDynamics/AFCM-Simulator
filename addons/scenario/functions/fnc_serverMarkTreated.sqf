/*
 * Author: Tasman Dynamics
 * Server-authoritative manual "treated" override for the Medical Tent completion check
 * (afcm_sim_scenario_fnc_isPatientTreated) - set from the "Mark as Treated" addAction every spawned
 * patient gets (afcm_sim_ui_fnc_addTreatedAction), same server-authority pattern as
 * serverApplyInjury/serverReset (DESIGN.md §6 - never applied/set client-side).
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

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};

_unit setVariable ["AFCM_SIM_treated", true, true];

diag_log text format ["[AFCM-Simulator] %1 manually marked treated.", _unit];
