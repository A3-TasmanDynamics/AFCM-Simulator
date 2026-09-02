/*
 * Author: Tasman Dynamics
 * ACE3-native cardiac arrest toggle, called directly rather than through the generic Injury/
 * backend-interface dispatch (same reasoning as fnc_applyFracture.sqf etc. in kat_compat) - cardiac
 * arrest is a whole-patient vitals state, not a per-limb wound, so it has no place in the
 * backend-agnostic Injury object.
 *
 * Real, confirmed mechanism (acemod/ACE3, addons/medical_status/functions/
 * fnc_setCardiacArrestState.sqf, fetched directly): `ace_medical_status_fnc_setCardiacArrestState`
 * is ACE3's own real, dedicated entry point - sets `ace_medical_vitals_inCardiacArrest` (real
 * variable) and heart rate (0 on arrest, 40 on revival), forces the patient unconscious when
 * entering arrest, and fires a real CBA local event (`"ace_cardiacArrest"`) other systems can react
 * to. Unlike Fracture/Pneumothorax/Airway, this is genuinely ACE-native, not KAT-specific - it
 * works identically under plain ACE3 with no KAT installed at all, which is why it's implemented
 * here in ace_compat rather than only in kat_compat.
 *
 * `ace_medical_fnc_fullHeal` (afcm_sim_ace_fnc_reset) already correctly exits cardiac arrest as a
 * side effect (confirmed from that function's own real source - it fires a real
 * `"ace_medical_CPRSucceeded"` local event when `IN_CRDC_ARRST` is true, which the ACE state
 * machine picks up), so no extra reset-side handling is needed here.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Arrest <BOOL> (default false) - true to put the unit into cardiac arrest, false to revive it
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", ["_arrest", false]];

if (isNull _unit) exitWith {};

[_unit, _arrest] call ace_medical_status_fnc_setCardiacArrestState;
