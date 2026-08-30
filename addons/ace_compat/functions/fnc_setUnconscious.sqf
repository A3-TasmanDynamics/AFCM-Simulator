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
 * Early-exits if already ACE-unconscious so the recurring re-lock safeguard in
 * fnc_spawnPatient.sqf doesn't spam a WARNING every 3s (ace_medical_fnc_setUnconscious itself
 * warns and no-ops on a redundant call).
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
