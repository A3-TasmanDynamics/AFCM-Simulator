/*
 * Author: Tasman Dynamics
 * KAT backend implementation of the setUnconscious interface function. Identical to
 * afcm_sim_ace_fnc_setUnconscious - KAT extends ACE's own medical state (KAT_COMPAT.md §3) rather
 * than replacing consciousness tracking, so the same real `ace_medical_fnc_setUnconscious` call
 * and "ACE_isUnconscious" variable apply here too. See fnc_setUnconscious.sqf in ace_compat for
 * the full explanation - this was the real root cause of patients "healing themselves"
 * (REFERENCES.md), and for why this now takes an explicit target state (the Injury Author's new
 * "Wake Up"/"Knock Out" toggle) instead of always forcing unconscious.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Unconscious <BOOL> (default true)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", ["_unconscious", true]];

if (isNull _unit || {!alive _unit}) exitWith {};
if ((_unit getVariable ["ACE_isUnconscious", false]) == _unconscious) exitWith {};

[_unit, _unconscious] call ace_medical_fnc_setUnconscious;
