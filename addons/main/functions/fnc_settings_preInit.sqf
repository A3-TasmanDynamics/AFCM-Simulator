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

// Governs the "AFCM: <Title>"/"AFCM: Spawn Patient" interaction added to an object synced to an
// Eden AFCM Patient module (addons/eden/functions/fnc_module_patientPlacement.sqf,
// addons/ui/functions/fnc_addSpawnPatientAction.sqf). Scroll Wheel is the default since ACE's
// interaction menu isn't guaranteed loaded - fnc_addSpawnPatientAction.sqf falls back to the scroll
// action per-client if ACE Interaction Menu is picked but ace_interact_menu isn't actually present
// on that specific client, so this setting can never leave someone with no way to trigger the spawn.
["afcm_sim_terminalInteractionMethod", "LIST",
    ["Patient Terminal Interaction Method", "How a player triggers the ""Spawn Patient"" interaction on an object synced to an AFCM Patient module. ACE Interaction Menu requires ACE3's interaction menu addon - falls back to Scroll Wheel per-client if it's not actually loaded."],
    "AFCM Medical Simulator",
    [[0, 1, 2], ["Scroll Wheel", "ACE Interaction Menu", "Both"], 0]
] call CBA_fnc_addSetting;

// Opt-in, default off - every spawned patient's "Edit Injuries" action is unrestricted today
// (fnc_addInjuryEditorAction.sqf's condition is a hardcoded "true"), and this setting leaves that
// unchanged unless a mission maker deliberately turns it on. When on, a player must first use the
// new "AFCM: Authorize Injury Editing" action on an Interactive Terminal's synced object
// (fnc_addTerminalAction.sqf) before Edit Injuries appears for them on any patient.
["afcm_sim_requireInjuryEditPermission", "CHECKBOX",
    ["Require Injury Edit Permission", "If enabled, a player can't use a patient's ""Edit Injuries"" action until they've used ""AFCM: Authorize Injury Editing"" on an Interactive Terminal's synced object at least once this mission. Off by default - every patient's Edit Injuries stays unrestricted unless this is turned on."],
    "AFCM Medical Simulator",
    false
] call CBA_fnc_addSetting;

// Real, confirmed CBA array-category form (the wiki's own code example is string-only, verified
// instead directly against CBA_A3's own fnc_init.sqf: `_categoryArg params [["_category", "", [""]],
// ["_subCategory", "", [""]]];` - index 0 is the top-level category, index 1 the sub-category,
// grouping these two under the same "AFCM Medical Simulator" top-level category as every other
// setting here while nesting them under their own headings. Both default true - these two scroll
// actions were always-on with no way to disable before this, so defaulting to true preserves
// existing behaviour for anyone who never touches the setting.
["afcm_sim_enableMarkAsTreated", "CHECKBOX",
    ["Enable ""Mark as Treated"" Action", "Adds the ""AFCM: Mark as Treated"" scroll-wheel action to every spawned patient - the manual half of Medical Tent's treated-detection (DESIGN.md § Medical Tent). Turn off to remove the action entirely."],
    ["AFCM Medical Simulator", "Training"],
    true
] call CBA_fnc_addSetting;

["afcm_sim_enableExportPatientState", "CHECKBOX",
    ["Enable ""Export Patient State"" Action", "Adds the ""AFCM: Export Patient State"" scroll-wheel action to every spawned patient, letting a controller copy their current injuries out as a reusable preset string (fnc_exportPatientState.sqf). Turn off to remove the action entirely."],
    ["AFCM Medical Simulator", "Scenario"],
    true
] call CBA_fnc_addSetting;
