/*
 * Author: Tasman Dynamics
 * KAT backend implementation of the setUnconscious interface function. Identical to
 * afcm_sim_ace_fnc_setUnconscious - KAT extends ACE's own medical state (KAT_COMPAT.md §3) rather
 * than replacing consciousness tracking, so the same real `ace_medical_fnc_setUnconscious` call
 * and "ACE_isUnconscious" variable apply here too. See fnc_setUnconscious.sqf in ace_compat for
 * the full explanation - this was the real root cause of patients "healing themselves"
 * (REFERENCES.md).
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

if (isNull _unit || {!alive _unit}) exitWith {};
if (_unit getVariable ["ACE_isUnconscious", false]) exitWith {};

[_unit, true] call ace_medical_fnc_setUnconscious;
