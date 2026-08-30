/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the applyInjury interface function.
 *
 * Real implementation, grounded directly against ACE3's own source (REFERENCES.md — fetched from
 * acemod/ACE3, not guessed):
 *  - `ace_medical_fnc_addDamageToUnit` drives ACE's normal damage-type-to-wound pipeline (random
 *    wound selection/severity per CfgWounds `ACE_Medical_Injuries > damageTypes`, confirmed real
 *    classes: bullet/grenade/explosive/shell/... ) - this is the baseline injury.
 *  - `ace_medical_fnc_addWound` is a separate, lower-level call used ONLY when the Injury object
 *    says `bleeding: true`, to deterministically guarantee a real bleeding wound exists rather than
 *    leaving it to addDamageToUnit's internal randomness (a "Medium" roll with bleeding=true could
 *    otherwise land on a non-bleeding Contusion and never bleed at all). `_woundDamage` is passed as
 *    0 so this doesn't double-count damage already applied above - it exists purely to add a sized,
 *    bleeding wound entry.
 *
 * Two gotchas confirmed from ACE3's real source, not the wiki (which doesn't document addWound at
 * all): addDamageToUnit lowercases its `_bodyPart` internally before matching, but addWound does
 * NOT - it requires the exact lowercase ALL_BODY_PARTS strings ("head"/"body"/"leftarm"/"rightarm"/
 * "leftleg"/"rightleg") or it silently fails to match and errors out. Wound type names for addWound
 * are case-sensitive and must match a real CfgWounds class name exactly (e.g. "VelocityWound", not
 * "velocitywound").
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Injury <HASHMAP> - see DESIGN.md §4.2
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_injury"];

if (isNull _unit) exitWith {};

// AFCM-Simulator's LimbId is a direct 1:1 match to ACE3's own 6 real body parts (INJURY_CODES.md
// §1) - deliberately, so there's no folding needed here. Lowercase ACE body part strings -
// required as-is for addWound, and also valid for addDamageToUnit (which lowercases internally
// regardless of case passed in).
private _bodyPartMap = createHashMapFromArray [
    ["head", "head"],
    ["chest", "body"],
    ["leftArm", "leftarm"],
    ["rightArm", "rightarm"],
    ["leftLeg", "leftleg"],
    ["rightLeg", "rightleg"]
];
private _damageTypeMap = createHashMapFromArray [
    ["gunshot", "bullet"],
    ["shrapnel", "grenade"],
    ["blast", "shell"]
];
// One representative real CfgWounds class per backend-agnostic woundType, used only for the forced
// bleeding wound below - matches each damage type's real weighting in ACE_Medical_Injuries.hpp
// (e.g. "bullet"'s VelocityWound is its own dedicated wound class; "grenade"/"shell" both weight
// PunctureWound heavily for smaller fragment wounds).
private _bleedWoundTypeMap = createHashMapFromArray [
    ["gunshot", "VelocityWound"],
    ["shrapnel", "PunctureWound"],
    ["blast", "PunctureWound"]
];

private _limb = _injury getOrDefault ["limb", "chest"];
private _woundType = _injury getOrDefault ["woundType", "gunshot"];
private _severity = _injury getOrDefault ["severity", 0.5];
private _bleeding = _injury getOrDefault ["bleeding", false];
private _bleedRate = _injury getOrDefault ["bleedRate", 0];

private _bodyPart = _bodyPartMap getOrDefault [_limb, "body"];
private _damageType = _damageTypeMap getOrDefault [_woundType, "bullet"];

[_unit, _severity, _bodyPart, _damageType] call ace_medical_fnc_addDamageToUnit;

if (_bleeding) then {
    private _bleedWoundType = _bleedWoundTypeMap getOrDefault [_woundType, "PunctureWound"];
    // Size 0/1/2 (small/medium/large) - the only lever ACE gives addWound over how much this
    // specific wound bleeds/hurts (`bleeding`/`pain` in ACE_Medical_Injuries.hpp are multiplied by
    // size). DESIGN.md §4.4's bleedRate values run roughly 0.1-0.4 in practice (afcm_sim_scenario's
    // randomizer) - bucketed into size here rather than scaled 1:1, since size is an enum not a
    // continuous value.
    private _size = 0;
    if (_bleedRate >= 0.3) then { _size = 2; } else {
        if (_bleedRate >= 0.15) then { _size = 1; };
    };
    [_unit, _bodyPart, [_bleedWoundType, 1, _size, 0]] call ace_medical_fnc_addWound;
};
