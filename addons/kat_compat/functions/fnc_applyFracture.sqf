/*
 * Author: Tasman Dynamics
 * KAT-specific (no ACE equivalent) - sets one limb's entry in the real `kat_surgery_fractures`
 * array (KAT_COMPAT.md §4/INJURY_CODES.md §6). Not part of the generic backend interface
 * (afcm_sim_fnc_backend_*) since this has no meaning under ACE alone or AFCM - called directly by
 * afcm_sim_scenario_fnc_serverApplyKatFracture, only reachable from the injury editor UI when KAT
 * is confirmed to be the active backend.
 *
 * Reads the existing array before writing so setting one limb's fracture doesn't clobber another
 * limb's already-set fracture.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1
 * 2: Severity <NUMBER> - 0=Unaffected, 1=Stable, 2=Compound, 3=Comminuted (INJURY_CODES.md §6)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_limb", "_severity"];

if (isNull _unit) exitWith {};

// Same LimbId -> ACE/KAT body part fold as fnc_applyInjury.sqf.
private _bodyPartMap = createHashMapFromArray [
    ["head", "head"], ["neck", "body"], ["chest", "body"], ["abdomen", "body"], ["pelvis", "body"],
    ["leftUpperArm", "leftarm"], ["leftForearm", "leftarm"],
    ["rightUpperArm", "rightarm"], ["rightForearm", "rightarm"],
    ["leftThigh", "leftleg"], ["leftShin", "leftleg"],
    ["rightThigh", "rightleg"], ["rightShin", "rightleg"]
];
private _bodyPart = _bodyPartMap getOrDefault [_limb, "body"];

// kat_surgery_fractures is indexed identically to ACE's ALL_BODY_PARTS (KAT_COMPAT.md §4).
private _allBodyParts = ["head", "body", "leftarm", "rightarm", "leftleg", "rightleg"];
private _index = _allBodyParts find _bodyPart;

if (_index == -1) exitWith {};

private _fractures = _unit getVariable ["kat_surgery_fractures", [0, 0, 0, 0, 0, 0]];
_fractures set [_index, _severity];
_unit setVariable ["kat_surgery_fractures", _fractures, true];
