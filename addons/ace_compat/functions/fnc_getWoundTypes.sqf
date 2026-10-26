/*
 * Author: Tasman Dynamics
 * ACE3 backend implementation of the getWoundTypes interface function - the real, confirmed list
 * of woundType ids this backend actually understands (afcm_sim_main_fnc_medical_
 * applyAceStyleInjuryLocal.sqf's own _damageTypeMap/_classMap), moved here from being a hardcoded
 * duplicate inside addons/ui's fnc_injuryAuthor_init.sqf/fnc_injuryAuthor_commitActiveLimbForm.sqf
 * (on request) so the Injury Author's WoundType combo is always built from the SAME single source
 * of truth the application logic itself uses, rather than two independently-maintained lists that
 * could drift out of sync.
 *
 * Every id/label pair here is a real, confirmed ACE3 class (docs/INJURY_CODES.md §2.1) - the three
 * probabilistic ones (gunshot/shrapnel/blast, via ace_medical_fnc_addDamageToUnit's damageTypes)
 * plus the seven deterministic CfgWounds classes (via ace_medical_fnc_addWound) - nothing outside
 * that real, already-wired set.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Array of [Id <STRING>, Label <STRING>] pairs, in display order
 *
 * Public: No
*/

[
    ["gunshot", "Gunshot"],
    ["shrapnel", "Shrapnel"],
    ["blast", "Blast"],
    ["abrasion", "Abrasion"],
    ["avulsion", "Avulsion"],
    ["contusion", "Contusion"],
    ["crush", "Crush"],
    ["cut", "Cut"],
    ["laceration", "Laceration"],
    ["thermalburn", "Thermal Burn"]
]
