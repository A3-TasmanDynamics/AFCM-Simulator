/*
 * Author: Tasman Dynamics
 * Registers AFCM-Simulator's CBA Addon Options. Runs at preInit (CBA's own recommendation, so the
 * settings are available in the Eden Editor too, not just in-game).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

["afcm_sim_debugLogging", "CHECKBOX",
    ["Debug Logging", "Verbose diag_log output for backend registration/selection and dispatch failures. Leave off unless troubleshooting."],
    "AFCM Medical Simulator",
    false
] call CBA_fnc_addSetting;

["afcm_sim_defaultInjuryLevel", "LIST",
    ["Default Injury Level", "Default randomization level pre-selected in the injury editor and Random Patient (DESIGN.md §4.4) — a gameplay-authoring difficulty, not a real triage category."],
    "AFCM Medical Simulator",
    [[0, 1, 2, 3, 4], ["Easy", "Medium", "Hard", "Extreme", "F*CKED!"], 1]
] call CBA_fnc_addSetting;

["afcm_sim_defaultCasualtyType", "LIST",
    ["Default Casualty Type", "Default clothing/appearance for spawned patients when a placed module doesn't override it via its own Casualty Type attribute. Purely visual — the unit is always stripped of weapons/gear regardless of type (DESIGN.md §5)."],
    "AFCM Medical Simulator",
    [[0, 1, 2, 3], ["Civilian", "Military (BLUFOR)", "Military (OPFOR)", "Military (Independent)"], 0]
] call CBA_fnc_addSetting;

["afcm_sim_rememberLastInjuries", "CHECKBOX",
    ["Remember Last-Used Injuries", "When authoring a new patient (Ctrl+Shift+I, no live unit yet), auto-restore whatever injuries/KAT extras were last applied instead of starting from a clean form. Use the Clear All button in that dialog to wipe the remembered set."],
    "AFCM Medical Simulator",
    false
] call CBA_fnc_addSetting;
