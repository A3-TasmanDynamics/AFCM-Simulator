/*
 * Author: Tasman Dynamics
 * Server-side handler for a KAT-specific airway selection (INJURY_CODES.md §6). Called directly
 * rather than through the generic afcm_sim_fnc_backend_applyInjury dispatch - it's a head/neck-wide
 * condition with no equivalent in the backend-agnostic Injury object. Guards on KAT actually being
 * the active backend before calling afcm_sim_kat_fnc_applyAirway directly, since that function only
 * exists to call if kat_compat's PBO is actually loaded on this machine.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Type <NUMBER> - 0=None, 1=Obstruction, 2=Occlusion
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", ["_type", 0]];

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};
if ((call afcm_sim_fnc_backend_getActive) != "kat") exitWith {
    diag_log text "[AFCM-Simulator] serverApplyKatAirway aborted - KAT is not the active backend.";
};

[_unit, _type] call afcm_sim_kat_fnc_applyAirway;
