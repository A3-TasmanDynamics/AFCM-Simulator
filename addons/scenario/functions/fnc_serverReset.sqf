/*
 * Author: Tasman Dynamics
 * Server-side handler for resetting a patient's medical state (DESIGN.md §5 "Selectable
 * Injuries" - the injury editor's Reset button). Called via remoteExec from afcm_sim_ui, never
 * called directly by a client - DESIGN.md §6 requires interventions to be requests validated and
 * applied on the server, same pattern as fnc_serverApplyInjury.sqf. Also clears
 * AFCM_SIM_appliedInjuries (fnc_backend_applyInjury.sqf's per-limb tracking) - otherwise a reset
 * patient's old wounds would keep reappearing in the injury author dialog's staging form on reopen,
 * even though the live backend state was genuinely wiped.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit"];

diag_log text format ["[AFCM-Simulator] serverReset received - unit %1 (isServer=%2).", _unit, isServer];

if !(isServer) exitWith {
    diag_log text "[AFCM-Simulator] serverReset aborted - not running on the server.";
};
if (isNull _unit) exitWith {
    diag_log text "[AFCM-Simulator] serverReset aborted - unit is objNull on the server.";
};

[_unit] call afcm_sim_fnc_backend_reset;
_unit setVariable ["AFCM_SIM_appliedInjuries", [], true];
