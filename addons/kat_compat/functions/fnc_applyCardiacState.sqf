/*
 * Author: Tasman Dynamics
 * KAT-specific cardiac arrest + rhythm toggle, called directly rather than through the generic
 * Injury/backend-interface dispatch (INJURY_CODES.md §6/§7 / KAT_COMPAT.md §4) - a whole-patient
 * vitals state, not a per-limb wound, with no place in the backend-agnostic Injury object.
 *
 * The base arrest flag is genuinely ACE-native, not KAT's own invention - real, confirmed from
 * `include/z/ace/addons/medical_engine/script_macros_medical.hpp` (vendored into KAT's own repo):
 * `IN_CRDC_ARRST(unit)` reads `ace_medical_vitals_inCardiacArrest`, set via the real
 * `ace_medical_status_fnc_setCardiacArrestState` (same call afcm_sim_ace_fnc_applyCardiacState
 * uses) - KAT's own vitals loop (addons/circulation/functions/fnc_updateHeartRate.sqf,
 * addons/vitals/functions/fnc_handleCardiacFunction.sqf) reads that exact same flag.
 *
 * Rhythm type IS real, confirmed KAT-specific detail on top of that base flag:
 * `kat_circulation_cardiacArrestType` (real, confirmed from KAT's own addons/circulation/functions/
 * fnc_handleCardiacArrest.sqf and fnc_getCardiacArrestHeartRate.sqf, both fetched directly this
 * pass - their own in-file comments doubly confirm the same 0-4 enum): 0=Normal, 1=Asystole
 * (no pulse, not shockable), 2=PEA (pulseless electrical activity, not shockable),
 * 3=Ventricular Fibrillation (shockable), 4=Ventricular Tachycardia (shockable). Only has a visible
 * effect if the mission has KAT's own "Advanced Cardiac Rhythm" setting
 * (`kat_circulation_AdvRhythm`) enabled - harmless, real KAT state either way, same as this
 * project's existing Fracture severity assuming KAT's surgery system is otherwise functioning.
 * Setting the variable directly is sufficient - both real KAT consumers above read it fresh on
 * their own periodic schedule, no companion "apply" call is needed (same as Airway, unlike
 * Pneumothorax's handleBreathing requirement).
 *
 * Deliberately deterministic, matching afcm_sim_kat_fnc_applyPneumothorax/applyFracture/
 * applyAirway - an instructor picking a rhythm here should get exactly that, not KAT's own
 * randomized deterioration cascade (fnc_handleCardiacArrest.sqf's own random-chance/time-based
 * logic, which this deliberately does not replicate).
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Rhythm <NUMBER> (default 0) - 0=Normal, 1=Asystole, 2=PEA, 3=Ventricular Fibrillation,
 *    4=Ventricular Tachycardia
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", ["_rhythm", 0]];

if (isNull _unit) exitWith {};

[_unit, _rhythm > 0] call ace_medical_status_fnc_setCardiacArrestState;
_unit setVariable ["kat_circulation_cardiacArrestType", _rhythm, true];
