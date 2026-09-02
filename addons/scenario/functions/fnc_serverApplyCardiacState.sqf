/*
 * Author: Tasman Dynamics
 * Server-side handler for a cardiac arrest/rhythm selection (INJURY_CODES.md §7). Called directly
 * rather than through the generic afcm_sim_fnc_backend_applyInjury dispatch - a whole-patient
 * vitals state with no equivalent in the backend-agnostic Injury object.
 *
 * Unlike serverApplyKatFracture/Pneumothorax/Airway, this is NOT KAT-only - the base cardiac arrest
 * flag is genuinely ACE-native (real, confirmed ace_medical_status_fnc_setCardiacArrestState, see
 * afcm_sim_ace_fnc_applyCardiacState's own header), so this dispatches to whichever of "ace"/"kat"
 * is actually active rather than guarding on one specific backend. KAT additionally tracks a real
 * rhythm type on top of the shared base flag (afcm_sim_kat_fnc_applyCardiacState); ACE has no
 * equivalent concept, so its own version only takes the base arrest bool (rhythm > 0).
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Rhythm <NUMBER> (default 0) - 0=Normal, 1=Asystole, 2=PEA, 3=Ventricular Fibrillation,
 *    4=Ventricular Tachycardia (KAT-only detail; under ACE, any value > 0 just means "in arrest")
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", ["_rhythm", 0]];

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};

private _backend = call afcm_sim_fnc_backend_getActive;

switch (_backend) do {
    case "kat": { [_unit, _rhythm] call afcm_sim_kat_fnc_applyCardiacState; };
    case "ace": { [_unit, _rhythm > 0] call afcm_sim_ace_fnc_applyCardiacState; };
    default {
        diag_log text format ["[AFCM-Simulator] serverApplyCardiacState aborted - active backend '%1' has no cardiac state support.", _backend];
    };
};
