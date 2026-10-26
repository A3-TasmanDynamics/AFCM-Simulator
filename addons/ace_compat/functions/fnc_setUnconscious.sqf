/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the setUnconscious interface function.
 *
 * This is NOT the same as the engine's own `setUnconscious` command. ACE tracks its own
 * unconsciousness independently via a "ACE_isUnconscious" variable (real macro, confirmed against
 * ACE3 source: `addons/medical_engine/script_macros_medical.hpp` -
 * `IS_UNCONSCIOUS(unit) = (unit getVariable ["ACE_isUnconscious", false])`), which is only ever
 * set correctly through `ace_medical_fnc_setUnconscious` (real, public function -
 * `addons/medical/functions/fnc_setUnconscious.sqf`). The engine command changes the ragdoll/anim
 * state but never touches that variable - so `ace_medical_ai`'s own CBA state machine
 * (addons/medical_ai/stateMachine.inc.sqf, ticks over every locally-known unit regardless of
 * `disableAI`) still saw patients as fully conscious and immediately self-treated them, which is
 * the real root cause of patients "healing themselves" (REFERENCES.md).
 *
 * Early-exits if already in the requested state so the recurring re-lock safeguard in
 * fnc_spawnPatient.sqf doesn't spam a WARNING every 3s (ace_medical_fnc_setUnconscious itself
 * warns and no-ops on a redundant call).
 *
 * Real, confirmed extension: now takes an explicit target state instead of always forcing
 * unconscious, so the same interface op covers the Injury Author's new "Wake Up"/"Knock Out"
 * toggle (fnc_injuryAuthor_onToggleConsciousness.sqf) too - every existing caller
 * (`[_unit] call afcm_sim_fnc_backend_setUnconscious;`, no 2nd arg) is unaffected, since the
 * default is still `true`. The early-exit guard now compares against the REQUESTED state, not just
 * "is unconscious" - the old unconditional check would have silently refused to ever wake a unit
 * back up, since it's unconscious by definition at that point.
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
