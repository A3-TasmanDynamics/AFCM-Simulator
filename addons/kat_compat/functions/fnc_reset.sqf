/*
 * Author: Tasman Dynamics
 * KAT - Advanced Medical backend implementation of the reset interface function. Identical to
 * afcm_sim_ace_compat's (KAT_COMPAT.md §3 - KAT extends ACE3's own medical state rather than
 * replacing it, so ace_medical_fnc_fullHeal applies correctly here too - including exiting cardiac
 * arrest, confirmed from ACE3's own fnc_fullHealLocal.sqf source, which fires a real
 * `"ace_medical_CPRSucceeded"` local event whenever `IN_CRDC_ARRST` is true) - PLUS clearing the
 * real KAT-only state (INJURY_CODES.md §6) that has no ACE equivalent, so ace_medical_fnc_fullHeal
 * cannot and does not clear it: `kat_circulation_cardiacArrestType` (see fnc_applyCardiacState.sqf)
 * as well as kat_surgery_fractures/kat_breathing_pneumothorax(+hemo/tension)/
 * kat_airway_obstruction(+occluded).
 *
 * Real, confirmed bug fixed here: this used to only call fullHeal/setUnconscious, leaving all of
 * the above completely untouched - a patient given a Comminuted fracture, then Reset, kept showing
 * "Fracture (KAT): Comminuted" in the live status readout forever after, since getState reads
 * straight from those never-cleared variables. Reset now genuinely wipes everything KAT-specific
 * too, not just the baseline ACE wound state - reuses the existing apply* functions with their own
 * "clear" value (0/None) rather than duplicating knowledge of each variable's shape here, which
 * also means this automatically inherits their own locality-correct dispatch
 * (afcm_sim_kat_fnc_applyPneumothorax/applyAirway, CBA_fnc_targetEvent) for free.
 *
 * Re-lock uses `ace_medical_fnc_setUnconscious`, not the engine's own `setUnconscious` command -
 * see fnc_setUnconscious.sqf for why the engine command alone doesn't actually stop ACE's own AI
 * from treating the unit.
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

if (isNull _unit) exitWith {};

[_unit] call ace_medical_fnc_fullHeal;
_unit setVariable ["kat_circulation_cardiacArrestType", 0, true];

_unit setVariable ["kat_surgery_fractures", [0, 0, 0, 0, 0, 0], true];
[_unit, 0] call afcm_sim_kat_fnc_applyPneumothorax;
[_unit, 0] call afcm_sim_kat_fnc_applyAirway;

[_unit] call afcm_sim_kat_fnc_setUnconscious;
