/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleSpawnRandomPatient (Zeus). Opens a real picker window
 * (RscDisplayAFCM_SIM_SpawnPatientPicker, ui/config.cpp) for the placing curator to choose Casualty
 * Type before anything spawns, on request ("it must open a window to choose the faction and unit
 * type of the patient first... should also save across patient creation") - the module's own
 * pre-existing Casualty Type Attribute still seeds the picker's own initial default
 * (afcm_sim_defaultCasualtyType) the very first time, but the picker itself is what actually
 * remembers the operator's last real choice (profileNamespace,
 * fnc_spawnPatientPicker_init.sqf/onSpawn.sqf) across separate module placements, which a static
 * config `defaultValue` genuinely cannot do.
 *
 * Spawns a clean, unconscious patient once confirmed - no randomized injuries. Injuries are
 * selected afterward via the Injury Author, auto-opened on the placing curator's own screen right
 * after spawning (fnc_spawnPatientPicker_onSpawn.sqf's own remoteExec callback - same real
 * limb-select -> injury-editor flow DESIGN.md §5 "Selectable Injuries" describes), rather than
 * requiring a manual scroll-to-"Edit Injuries" step on the newly spawned unit.
 *
 * Class/function names still say "RandomPatient" for historical reasons (renaming the Zeus module
 * class would orphan it in any mission that's already placed one) — the display name
 * ("Spawn Patient", zeus/config.cpp) no longer claims randomization.
 *
 * `local _logic` (true ONLY on the placing curator's own machine) is what opens the picker -
 * fnc_spawnPatientPicker_open.sqf/onSpawn.sqf/cleanup.sqf own the module logic's lifetime from here
 * (spawning via remoteExec to the server, deleting `_logic` locally once the picker closes either
 * way) - there's nothing left for THIS function to do once the picker is up.
 *
 * Guards against firing more than once per placed module (`AFCM_SIM_moduleFired`, a variable
 * stashed on `_logic` itself) - vanilla Module_F's function has no guaranteed single-fire
 * behaviour (confirmed independently by ACE3's own Modules Framework docs, which built their own
 * wrapper specifically because "there is no guarantee" here), and re-firing would otherwise open a
 * duplicate picker silently.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed module
 * 1: Units <ARRAY> - synced units, if any
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_logic", "_units", "_activated"];

// Diagnostic-only, temporary - added alongside fnc_main_postInit.sqf's own CfgPatches/CfgVehicles
// check (PR #46) to chase down "Zeus modules don't work" reports. If this line never shows up in
// the RPT at all when the module is placed, the module function itself isn't even being reached -
// narrows the problem down to placement/Module_F activation rather than anything in this file.
diag_log text format ["[AFCM-Simulator][Zeus][diag] Spawn Patient module fired - activated=%1, isServer=%2, local=%3, moduleFired=%4.", _activated, isServer, local _logic, _logic getVariable ["AFCM_SIM_moduleFired", false]];

if !(_activated) exitWith {};
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};
_logic setVariable ["AFCM_SIM_moduleFired", true];

if (local _logic) then {
    [_logic] call afcm_sim_ui_fnc_spawnPatientPicker_open;
};
