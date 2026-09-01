/*
 * Author: Tasman Dynamics
 * Adds two vanilla addActions ("AFCM: Open MCI Creator" / "AFCM: Open Session Manager") to a
 * placed object - run via remoteExec (target 0 = everyone, JIP-persisted) from
 * afcm_sim_eden_fnc_module_interactiveTerminal, same reasoning as fnc_addInjuryEditorAction.sqf:
 * addAction is inherently local to whichever machine calls it, so every client (present and JIP)
 * needs to run this itself for the actions to actually show up for them.
 *
 * No real vanilla addAction submenu/parentId mechanism exists (confirmed - the BI wiki and
 * community discussion around addAction only document a flat action list, workarounds like
 * removeAllActions rebuilding are the closest thing to nesting), so this deliberately adds two
 * flat, "AFCM:"-prefixed actions instead of one action with a nested choice - same grouping-by-name
 * convention already used elsewhere in this addon ("AFCM: Edit Injuries", "AFCM: Assign MCI
 * Preset").
 *
 * Arguments:
 * 0: Object <OBJECT> - whatever the Interactive Terminal module was attached to (a placed Laptop,
 *    a table, anything)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_object"];

if (isNull _object) exitWith {};

_object addAction [
    "<t color='#c1272d'>AFCM: Open MCI Creator</t>",
    { call afcm_sim_ui_fnc_mciCreator_open; },
    [],
    1.5,
    true,
    true,
    "",
    "true",
    5
];

_object addAction [
    "<t color='#c1272d'>AFCM: Open Session Manager</t>",
    { call afcm_sim_ui_fnc_sessionManager_open; },
    [],
    1.4,
    true,
    true,
    "",
    "true",
    5
];

diag_log text format ["[AFCM-Simulator][UI] Terminal actions added to %1.", _object];
