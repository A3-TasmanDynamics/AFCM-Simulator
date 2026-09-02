/*
 * Author: Tasman Dynamics
 * The real, shared ACE3 injury-application logic both ace_compat and kat_compat use (KAT extends
 * ACE3's own wound pipeline rather than replacing it, KAT_COMPAT.md §3 - the two were previously
 * byte-for-byte duplicated copies of this same function). Lives here in afcm_sim_main, not either
 * compat addon, specifically so it can be registered as ONE shared CBA event
 * ("afcm_sim_applyAceStyleInjuryLocal", fnc_medical_registerEvents.sqf) that both addons' own thin
 * fnc_applyInjury.sqf dispatch into via CBA_fnc_targetEvent.
 *
 * That event dispatch is the actual fix here, not just a dedup: `ace_medical_fnc_addDamageToUnit`
 * requires `local _unit` (REFERENCES.md, confirmed directly from ACE3's own source) - calling it
 * unconditionally on the server (this codebase's prior behaviour) silently no-ops for any unit not
 * local to the server, e.g. a live player-controlled casualty. `CBA_fnc_targetEvent` (real, confirmed
 * from CBATeam/CBA_A3's own addons/events/fnc_targetEvent.sqf) runs a registered event's handler on
 * whichever machine the target object is actually local to - the exact real mechanism KAT's own
 * source uses for the same class of problem (e.g. addons/airway/functions/
 * fnc_treatmentAdvanced_airway.sqf dispatches to a "...Local"-suffixed function the same way).
 *
 * Grounded directly against ACE3's own source (REFERENCES.md - fetched from acemod/ACE3, not
 * guessed):
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
 * Arguments (from CBA_fnc_targetEvent, matching its real _params-becomes-_this shape - confirmed
 * from KAT's own real "...Local" functions):
 * 0: Target unit <OBJECT>
 * 1: Injury <HASHMAP> - see DESIGN.md §4.2
 * 2: Backend label <STRING> - "ACE" or "KAT", for logging only
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_injury", ["_backendLabel", "ACE"]];

if (isNull _unit) exitWith {};
// Real, confirmed failure mode (RPT log): a caller handing this the lighter [limb, woundType,
// severity, bleeding] Array shape (Preset injury entries, INJURY_CODES.md §4) instead of a real
// Injury HashMap (DESIGN.md §4.2) - `getOrDefault` below requires a HashMap and throws a hard
// script error otherwise. Every real caller in this addon goes through
// afcm_sim_scenario_fnc_buildInjury first, so a non-HashMap here means a caller bug - fail
// gracefully with a diag_log instead of spamming the RPT with the same script error every time.
if (typeName _injury != "HASHMAP") exitWith {
    diag_log text format ["[AFCM-Simulator][%1 backend] applyInjury aborted - _injury is %2, not a HashMap (caller bug - see afcm_sim_scenario_fnc_buildInjury).", _backendLabel, typeName _injury];
};

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

if !(_limb in _bodyPartMap) then {
    diag_log text format ["[AFCM-Simulator][%1 backend] applyInjury - unrecognized limb '%2', falling back to chest (caller bug - check the LimbId spelling/casing, INJURY_CODES.md §1).", _backendLabel, _limb];
};
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
