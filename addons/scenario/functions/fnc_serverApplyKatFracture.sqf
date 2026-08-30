/*
 * Author: Tasman Dynamics
 * Server-side handler for a KAT-specific fracture selection (INJURY_CODES.md §6). Called directly
 * rather than through the generic afcm_sim_fnc_backend_applyInjury dispatch - fracture has no
 * equivalent in the backend-agnostic Injury object. Guards on KAT actually being the active
 * backend before calling afcm_sim_kat_fnc_applyFracture directly, since that function only exists
 * to call if kat_compat's PBO is actually loaded on this machine (unlike the generic dispatch,
 * which safely no-ops via the backend registry lookup instead).
 *
 * Arms/legs only - rejects head/chest server-side too, not just in the UI
 * (fnc_injuryEditor_init.sqf only shows the control for arm/leg selections), so this stays true
 * regardless of what calls it.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1 - must be an arm or a leg
 * 2: Fracture severity <NUMBER> - 0=None, 1=Simple, 2=Compound, 3=Comminuted
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_limb", ["_severity", 0]];

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};
if ((call afcm_sim_fnc_backend_getActive) != "kat") exitWith {
    diag_log text "[AFCM-Simulator] serverApplyKatFracture aborted - KAT is not the active backend.";
};
if !(_limb in ["leftArm", "rightArm", "leftLeg", "rightLeg"]) exitWith {
    diag_log text format ["[AFCM-Simulator] serverApplyKatFracture aborted - limb '%1' is not an arm or a leg.", _limb];
};

[_unit, _limb, _severity] call afcm_sim_kat_fnc_applyFracture;
