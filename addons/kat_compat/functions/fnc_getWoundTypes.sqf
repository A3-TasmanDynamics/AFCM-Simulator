/*
 * Author: Tasman Dynamics
 * KAT backend implementation of the getWoundTypes interface function - identical list to
 * ace_compat's own fnc_getWoundTypes.sqf, not a separate duplicate-by-coincidence: KAT_COMPAT.md
 * §3's real, confirmed finding is that KAT extends ACE3's own wound pipeline rather than replacing
 * it, and kat_compat's own fnc_applyInjury.sqf dispatches to the exact same shared
 * afcm_sim_main_fnc_medical_applyAceStyleInjuryLocal.sqf ace_compat's does - there is no separate
 * KAT wound-class taxonomy underneath these woundType ids. KAT's own genuinely distinct mechanics
 * (Fracture severity/Pneumothorax/Airway/Cardiac Rhythm) are already separate, backend-aware combos
 * elsewhere in the Injury Author, not part of this list.
 *
 * Gunshot/Shrapnel/Blast deliberately NOT included here (on request, "don't use anything outside of
 * those wound class's") - same reasoning as ace_compat's own fnc_getWoundTypes.sqf.
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
