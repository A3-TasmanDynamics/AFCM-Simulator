/*
 * Author: Tasman Dynamics
 * KAT - Advanced Medical backend implementation of the reset interface function. Identical to
 * afcm_sim_ace_compat's (KAT_COMPAT.md §3 - KAT extends ACE3's own medical state rather than
 * replacing it, so ace_medical_fnc_fullHeal applies correctly here too).
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
_unit setUnconscious true;
