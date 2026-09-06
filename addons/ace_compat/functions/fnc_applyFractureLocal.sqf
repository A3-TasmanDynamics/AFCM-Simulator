/*
 * Author: Tasman Dynamics
 * Real work for fnc_applyFracture.sqf - registered as the "afcm_sim_ace_applyFractureLocal" CBA
 * event handler (this addon's own fnc_preInit.sqf) so it runs on whichever machine the target unit
 * is actually local to. `ace_medical_engine_fnc_updateDamageEffects` (real, confirmed from
 * acemod/ACE3, REFERENCES.md) requires `local _unit` and errors otherwise - same class of problem
 * afcm_sim_main_fnc_medical_applyAceStyleInjuryLocal.sqf already solves for `addDamageToUnit`, but
 * this one isn't shared with kat_compat (KAT tracks its own, entirely separate
 * `kat_surgery_fractures`), so it's registered here in ace_compat rather than afcm_sim_main -
 * registering the exact same event name from two different compat addons would fire the handler
 * twice on any machine with both loaded, which is exactly why the shared injury-application event
 * lives in main instead (see fnc_medical_registerEvents.sqf's own reasoning); this one has no such
 * risk since only ace_compat ever registers or fires it.
 *
 * Real, confirmed mechanism (acemod/ACE3, addons/medical_damage/functions/
 * fnc_woundsHandlerBase.sqf / addons/medical_engine/script_macros_medical.hpp, REFERENCES.md):
 * `ace_medical_fractures` is a 6-element array (ALL_BODY_PARTS order - the exact same order
 * AFCM-Simulator's own LimbId already uses 1:1, INJURY_CODES.md §1) - `0` none, `1` fractured,
 * `-1` fractured-but-splinted. Only arms/legs (body part index > 1) ever fracture under real ACE
 * gameplay; this function trusts its caller (afcm_sim_scenario_fnc_serverApplyFracture) to have
 * already rejected head/chest, same as kat_compat's own equivalent.
 *
 * Arguments (from CBA_fnc_targetEvent, matching its real _params-becomes-_this shape):
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> - must be an arm or a leg
 * 2: Fractured <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_limb", ["_fractured", false]];

if (isNull _unit) exitWith {};

private _limbIndex = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"] find _limb;
if (_limbIndex == -1) exitWith {};

private _fractures = _unit getVariable ["ace_medical_fractures", [0, 0, 0, 0, 0, 0]];
_fractures set [_limbIndex, [0, 1] select _fractured];
_unit setVariable ["ace_medical_fractures", _fractures, true];

[_unit] call ace_medical_engine_fnc_updateDamageEffects;
