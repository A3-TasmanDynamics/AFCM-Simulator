/*
 * Author: Tasman Dynamics
 * KAT - Advanced Medical backend implementation of the applyInjury interface function.
 *
 * Real implementation, identical in substance to afcm_sim_ace_compat's (see that addon's
 * fnc_applyInjury.sqf/ACE_COMPAT.md §3 for the full rationale) - confirmed directly from KAT's own
 * source (KAT_COMPAT.md §3) that KAT does NOT replace ACE3's damage-application API, it registers
 * additional wound handlers into ACE3's own real `ACE_Medical_Injuries` config tree
 * (`addons/breathing/ACE_Medical_Injuries.hpp`, `addons/chemical/ACE_Medical_Injuries.hpp`). So the
 * same two real ACE3 calls apply correctly under KAT too, with KAT's own systems (pneumothorax,
 * tamponade, chemical burns) triggering automatically as a side effect - no separate KAT-specific
 * damage call exists or is needed for this.
 *
 * This was previously a stub specifically because that research hadn't been done yet - it has been
 * now (KAT_COMPAT.md), so leaving this as a stub was actively wrong: since kat_compat outranks
 * ace_compat (priority 15 vs 10, DESIGN.md §2.5), any server running ACE3+KAT had every injury
 * application - randomizer, Zeus/Eden spawns, and the manual injury editor - silently no-op here.
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
// Real, confirmed failure mode (RPT log): a caller handing this the lighter [limb, woundType,
// severity, bleeding] Array shape (Preset injury entries, INJURY_CODES.md §4) instead of a real
// Injury HashMap (DESIGN.md §4.2) - `getOrDefault` below requires a HashMap and throws a hard
// script error otherwise. Every real caller in this addon goes through
// afcm_sim_scenario_fnc_buildInjury first, so a non-HashMap here means a caller bug - fail
// gracefully with a diag_log instead of spamming the RPT with the same script error every time.
if (typeName _injury != "HASHMAP") exitWith {
    diag_log text format ["[AFCM-Simulator][KAT backend] applyInjury aborted - _injury is %1, not a HashMap (caller bug - see afcm_sim_scenario_fnc_buildInjury).", typeName _injury];
};

// Same 1:1 LimbId -> ACE body part map as afcm_sim_ace_compat's fnc_applyInjury.sqf (KAT sits on
// the same 6 real ACE body parts underneath - KAT_COMPAT.md §4).
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
    private _size = 0;
    if (_bleedRate >= 0.3) then { _size = 2; } else {
        if (_bleedRate >= 0.15) then { _size = 1; };
    };
    [_unit, _bodyPart, [_bleedWoundType, 1, _size, 0]] call ace_medical_fnc_addWound;
};

diag_log text format ["[AFCM-Simulator][KAT backend] applyInjury: %1 limb=%2 bodyPart=%3 woundType=%4 severity=%5 bleeding=%6.", _unit, _limb, _bodyPart, _woundType, _severity, _bleeding];
