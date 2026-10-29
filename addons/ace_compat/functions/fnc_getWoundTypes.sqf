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
 * Every id/label pair here is a real, confirmed ACE3 CfgWounds class (docs/INJURY_CODES.md §2.1),
 * applied deterministically via ace_medical_fnc_addWound - nothing outside that real set. Gunshot/
 * Shrapnel/Blast deliberately NOT included here (on request, "don't use anything outside of those
 * wound class's") - those were ACE's probabilistic damageType labels, not real CfgWounds class
 * names, and are no longer offered as choices; fnc_medical_applyAceStyleInjuryLocal.sqf keeps
 * applying them correctly if an already-saved preset still references one, it's just not a new
 * pick here. Puncture/Velocity added here instead - the exact real PunctureWound/VelocityWound
 * classes that legacy path already used internally for forced bleeding, now directly selectable.
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
    ["abrasion", "Abrasion"],
    ["avulsion", "Avulsion"],
    ["contusion", "Contusion"],
    ["crush", "Crush"],
    ["cut", "Cut"],
    ["laceration", "Laceration"],
    ["puncture", "Puncture Wound"],
    ["thermalburn", "Thermal Burn"],
    ["velocity", "Velocity Wound"]
]
