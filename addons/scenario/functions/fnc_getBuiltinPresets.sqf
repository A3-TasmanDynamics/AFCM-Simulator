/*
 * Author: Tasman Dynamics
 * Returns AFCM-Simulator's built-in injury preset library (DESIGN.md §4.3/§ Injury Presets) -
 * hardcoded, shipped with the addon, not editable/deletable from the Preset Library UI (unlike
 * user-saved presets, see fnc_getUserPresets.sqf).
 *
 * Preset shape (a plain Array, not a HashMap - see fnc_exportPreset.sqf for why):
 * [id <STRING>, name <STRING>, author <STRING>, description <STRING>,
 *  injuries <ARRAY of [limb, woundType, severity, bleeding]>, tags <ARRAY of STRING>,
 *  katExtras <ARRAY> (optional, 7th element)]
 *
 * Each injuries entry uses the same 4 real primitives afcm_sim_scenario_fnc_serverApplyInjury
 * already takes (LimbId/woundType/severity/bleeding, DESIGN.md §4.1/§4.2/INJURY_CODES.md) - a
 * preset is just a named, reusable batch of those. Only the first 5 presets below are 6-element
 * (no 7th katExtras) - the last 3, added for the Eden AFCM Patient module's Training Preset combo
 * (addons/eden/config.cpp), use katExtras (`[fractures <ARRAY[6]>, pneumothoraxType, airwayType,
 * cardiacRhythm]`) directly rather than only ever coming from a live-patient export, since that's the
 * real mechanism for airway/fracture-focused training. Every consumer of this shape
 * (fnc_parseExportedPreset.sqf/fnc_serverApplyPreset.sqf/fnc_saveUserPreset.sqf) already treats it as
 * optional, defaulting to "none" when absent - so a mix of 6- and 7-element entries in this same
 * array is valid either way.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Presets <ARRAY of Preset>
 *
 * Public: Yes
*/

[
    [
        "builtin_gsw_chest", "GSW — Chest", "Tasman Dynamics",
        "Single gunshot wound to the chest, moderate severity, actively bleeding.",
        [["chest", "gunshot", 0.6, true]],
        ["GSW", "single"]
    ],
    [
        "builtin_gsw_limb_tq", "GSW — Limb (Tourniquet Candidate)", "Tasman Dynamics",
        "Gunshot wound to the left arm, bleeding heavily enough to warrant a tourniquet.",
        [["leftArm", "gunshot", 0.5, true]],
        ["GSW", "tourniquet"]
    ],
    [
        "builtin_blast_casualty", "Blast Casualty", "Tasman Dynamics",
        "Chest and leg trauma from an explosive - both bleeding.",
        [["chest", "blast", 0.7, true], ["leftLeg", "blast", 0.5, true]],
        ["blast", "multi"]
    ],
    [
        "builtin_frag_multiple", "Frag Wounds (Multiple)", "Tasman Dynamics",
        "Shrapnel across three limbs from a nearby detonation - mixed bleeding.",
        [["rightArm", "shrapnel", 0.3, true], ["leftLeg", "shrapnel", 0.3, false], ["chest", "shrapnel", 0.2, false]],
        ["shrapnel", "multi"]
    ],
    [
        "builtin_minor_laceration", "Training — Minor Laceration", "Tasman Dynamics",
        "Low-severity, non-bleeding wound. Good first scenario for new trainees.",
        [["leftArm", "shrapnel", 0.15, false]],
        ["training", "minor"]
    ],
    // 3 more below, added for the Eden AFCM Patient module's Training Preset combo
    // (addons/eden/config.cpp) - that combo's Values list maps positionally to THIS array (index+1 =
    // combo value), so its order/count must stay in sync with this one; see its own comment.
    [
        "builtin_airway_obstruction", "Airway — Obstruction", "Tasman Dynamics",
        "Facial/head trauma with a compromised airway requiring immediate airway management - minimal external bleeding, the focus is airway control, not the wound itself.",
        [["head", "blast", 0.25, false]],
        ["airway", "training"],
        [[0, 0, 0, 0, 0, 0], 0, 1, 0]
    ],
    [
        "builtin_fracture_multiple", "Fractures — Multiple Limb", "Tasman Dynamics",
        "Closed fractures to both legs and one arm from a fall/blast, minimal bleeding - practice fracture immobilization/splinting across several limbs at once.",
        [["leftArm", "blast", 0.25, false], ["leftLeg", "blast", 0.3, false], ["rightLeg", "blast", 0.3, false]],
        ["fracture", "training"],
        [[0, 0, 2, 0, 3, 3], 0, 0, 0]
    ],
    [
        "builtin_severe_hemorrhage", "Severe Hemorrhage (Multi-Site)", "Tasman Dynamics",
        "Heavy, actively bleeding wounds across three sites at once - aggressive tourniquet/pressure-dressing drill under time pressure.",
        [["leftArm", "gunshot", 0.8, true], ["rightLeg", "gunshot", 0.75, true], ["chest", "shrapnel", 0.6, true]],
        ["hemorrhage", "severe", "training"]
    ]
]
