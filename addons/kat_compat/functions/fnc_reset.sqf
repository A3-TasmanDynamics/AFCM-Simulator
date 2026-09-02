/*
 * Author: Tasman Dynamics
 * KAT - Advanced Medical backend implementation of the reset interface function. Identical to
 * afcm_sim_ace_compat's (KAT_COMPAT.md §3 - KAT extends ACE3's own medical state rather than
 * replacing it, so ace_medical_fnc_fullHeal applies correctly here too - including exiting cardiac
 * arrest, confirmed from ACE3's own fnc_fullHealLocal.sqf source, which fires a real
 * `"ace_medical_CPRSucceeded"` local event whenever `IN_CRDC_ARRST` is true).
 *
 * fullHeal does NOT clear `kat_circulation_cardiacArrestType` though - a real, KAT-only variable
 * (see fnc_applyCardiacState.sqf) ACE's own fullHeal has no knowledge of, same class of gap as
 * kat_surgery_fractures/kat_breathing_pneumothorax etc. - cleared explicitly here for the same
 * reason.
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
[_unit] call afcm_sim_kat_fnc_setUnconscious;
