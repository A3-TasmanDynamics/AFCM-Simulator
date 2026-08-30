/*
 * Author: Tasman Dynamics
 * Returns AFCM-Simulator's built-in MCI (Mass Casualty Incident) preset library - a named,
 * reusable INCIDENT, not a single injury: each patient slot in it can carry its own distinct
 * injury Preset, e.g. "a HE shell hit a section, 3 are down, but with different injuries."
 *
 * MciPreset shape (a plain Array, same reasoning as Preset itself - fnc_exportPreset.sqf - a
 * HashMap doesn't round-trip through str/call compile, an Array does):
 * [id <STRING>, name <STRING>, author <STRING>, description <STRING>,
 *  patientSpecs <ARRAY of STRING>]
 *
 * Each patientSpecs entry is either a real Preset id (fnc_getBuiltinPresets.sqf/
 * fnc_getUserPresets.sqf - that patient gets that preset's exact injuries) or the literal string
 * "random" (that patient gets a freshly-rolled random injury set via
 * afcm_sim_scenario_fnc_randomizeInjuries at afcm_sim_defaultInjuryLevel) - resolved per-patient at
 * spawn time by fnc_resolveMciPatientSpec.sqf, never baked into the stored MciPreset itself.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * MciPresets <ARRAY of MciPreset>
 *
 * Public: Yes
*/

[
    [
        "builtin_mci_he_shell_3", "HE Shell — 3 Casualties", "Tasman Dynamics",
        "A single HE shell impact on a squad position - three down with different wounds.",
        ["builtin_gsw_limb_tq", "builtin_blast_casualty", "builtin_minor_laceration"]
    ],
    [
        "builtin_mci_ied_4", "IED Strike — 4 Casualties", "Tasman Dynamics",
        "Roadside IED against a moving element - varied blast/frag wounds plus one unpredictable case.",
        ["builtin_blast_casualty", "builtin_frag_multiple", "builtin_gsw_chest", "random"]
    ],
    [
        "builtin_mci_ambush_2", "Ambush — 2 Casualties", "Tasman Dynamics",
        "Small-arms contact, two casualties down.",
        ["builtin_gsw_chest", "builtin_gsw_limb_tq"]
    ]
]
