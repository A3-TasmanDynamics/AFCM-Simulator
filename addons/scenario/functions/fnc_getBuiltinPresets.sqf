/*
 * Author: Tasman Dynamics
 * Returns AFCM-Simulator's built-in injury preset library (DESIGN.md §4.3/§ Injury Presets) -
 * hardcoded, shipped with the addon, not editable/deletable from the Preset Library UI (unlike
 * user-saved presets, see fnc_getUserPresets.sqf).
 *
 * Preset shape (a plain Array, not a HashMap - see fnc_exportPreset.sqf for why):
 * [id <STRING>, name <STRING>, author <STRING>, description <STRING>,
 *  injuries <ARRAY of [limb, woundType, severity, bleeding]>, tags <ARRAY of STRING>]
 *
 * Each injuries entry uses the same 4 real primitives afcm_sim_scenario_fnc_serverApplyInjury
 * already takes (LimbId/woundType/severity/bleeding, DESIGN.md §4.1/§4.2/INJURY_CODES.md) - a
 * preset is just a named, reusable batch of those.
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
    ]
]
