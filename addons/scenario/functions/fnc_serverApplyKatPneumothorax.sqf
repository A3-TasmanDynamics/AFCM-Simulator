/*
 * Author: Tasman Dynamics
 * Server-side handler for a KAT-specific pneumothorax selection (INJURY_CODES.md §6). Called
 * directly rather than through the generic afcm_sim_fnc_backend_applyInjury dispatch - it's a
 * torso-wide condition with no equivalent in the backend-agnostic Injury object. Guards on KAT
 * actually being the active backend before calling afcm_sim_kat_fnc_applyPneumothorax directly,
 * since that function only exists to call if kat_compat's PBO is actually loaded on this machine.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Type <NUMBER> - 0=None, 1=Simple Pneumothorax, 2=Hemopneumothorax, 3=Tension Pneumothorax
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
    diag_log text "[AFCM-Simulator] serverApplyKatPneumothorax aborted - KAT is not the active backend.";
};

[_unit, _type] call afcm_sim_kat_fnc_applyPneumothorax;
