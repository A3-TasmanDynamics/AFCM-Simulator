/*
 * Author: Tasman Dynamics
 * Server-side handler for a KAT-specific fracture (INJURY_CODES.md §6) - not part of the generic
 * Injury object/backend interface, so this is a dedicated request path rather than going through
 * afcm_sim_fnc_backend_applyInjury. Only reachable from the injury editor UI when KAT is confirmed
 * the active backend; re-checked here server-side too in case the active backend changed between
 * the dialog opening and Apply being clicked.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1
 * 2: Severity <NUMBER> - 0=Unaffected, 1=Stable, 2=Compound, 3=Comminuted
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_limb", "_severity"];

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};

if ((missionNamespace getVariable ["AFCM_SIM_activeBackend", ""]) != "kat") exitWith {
    diag_log text "[AFCM-Simulator] serverApplyKatFracture ignored - kat is not the active backend.";
};

[_unit, _limb, _severity] call afcm_sim_kat_fnc_applyFracture;
