/*
 * Author: Tasman Dynamics
 * Server-side handler for a fracture selection (INJURY_CODES.md §6). Called directly rather than
 * through the generic afcm_sim_fnc_backend_applyInjury dispatch - fracture has no equivalent in
 * the backend-agnostic Injury object.
 *
 * Renamed from the old KAT-only fnc_serverApplyKatFracture.sqf - fracture turned out to NOT be
 * KAT-exclusive after all (REFERENCES.md has the full traced ACE3 source): ACE3's own
 * `ace_medical_engine` has a real, native per-limb fracture mechanic, just a plain fractured/not
 * Bool rather than KAT's own 0-3 Simple/Compound/Comminuted severity scale (an entirely separate
 * variable, `ace_medical_fractures` vs `kat_surgery_fractures` - the two backends' own fracture
 * states don't share storage). Same dispatch-by-active-backend shape as
 * fnc_serverApplyCardiacState.sqf, not a guard on one specific backend like the old function was.
 *
 * The single canonical `_severity` value staged by the Injury Author dialog (0-3, KAT's own scale)
 * is still what's threaded through here regardless of active backend - ACE's own applyFracture
 * just collapses it to a Bool (`_severity > 0`) at the final dispatch step, so a Preset/export
 * authored under KAT still applies sensibly (as "fractured, no severity detail") if later used
 * under a plain-ACE-only session, and vice versa.
 *
 * Arms/legs only - rejects head/chest server-side too, not just in the UI, so this stays true
 * regardless of what calls it.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1 - must be an arm or a leg
 * 2: Fracture severity <NUMBER> - 0=None, 1=Simple, 2=Compound, 3=Comminuted (KAT scale; under ACE,
 *    any value > 0 just means "fractured")
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_limb", ["_severity", 0]];

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};
if !(_limb in ["leftArm", "rightArm", "leftLeg", "rightLeg"]) exitWith {
    diag_log text format ["[AFCM-Simulator] serverApplyFracture aborted - limb '%1' is not an arm or a leg.", _limb];
};

private _backend = call afcm_sim_fnc_backend_getActive;

switch (_backend) do {
    case "kat": { [_unit, _limb, _severity] call afcm_sim_kat_fnc_applyFracture; };
    case "ace": { [_unit, _limb, _severity > 0] call afcm_sim_ace_fnc_applyFracture; };
    default {
        diag_log text format ["[AFCM-Simulator] serverApplyFracture aborted - active backend '%1' has no fracture support.", _backend];
    };
};
