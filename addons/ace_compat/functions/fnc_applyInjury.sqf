/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the applyInjury interface function.
 *
 * Real implementation, using ace_medical_fnc_addDamageToUnit (REFERENCES.md — confirmed against
 * the wiki and a prior working prototype). LimbId -> ACE3 hitpoint mapping matches DESIGN.md §4.1.
 * woundType -> ACE3 damage-type mapping is this addon's own choice (DESIGN.md §4.2 — woundType is
 * backend-agnostic, each backend maps it itself); values match what the prior working prototype
 * used in practice.
 *
 * Does not set unconsciousness or adjust pain directly — ACE3's own wound system derives those
 * from the damage applied, and forcing them here for every injury regardless of severity would be
 * wrong (a minor arm wound should not knock someone out).
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

private _hitpointMap = createHashMapFromArray [
    ["head", "Head"],
    ["torso", "Body"],
    ["armLeft", "LeftArm"],
    ["armRight", "RightArm"],
    ["legLeft", "LeftLeg"],
    ["legRight", "RightLeg"]
];
private _damageTypeMap = createHashMapFromArray [
    ["gunshot", "bullet"],
    ["shrapnel", "grenade"],
    ["blast", "shell"]
];

private _limb = _injury getOrDefault ["limb", "torso"];
private _woundType = _injury getOrDefault ["woundType", "gunshot"];
private _severity = _injury getOrDefault ["severity", 0.5];

private _hitpoint = _hitpointMap getOrDefault [_limb, "Body"];
private _damageType = _damageTypeMap getOrDefault [_woundType, "bullet"];

[_unit, _severity, _hitpoint, _damageType] call ace_medical_fnc_addDamageToUnit;
