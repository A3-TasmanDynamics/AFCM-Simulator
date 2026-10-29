/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleSpawnRandomPatient (Zeus). Spawns a clean, unconscious
 * patient at the module's placement position — no randomized injuries anymore. Injuries are
 * selected afterward via the Injury Author, auto-opened on the placing curator's own screen right
 * after spawning (on request - "Starts with a window to select faction/type of patient [the
 * module's own pre-existing Casualty Type attribute, set via Zeus's own pre-placement attributes
 * panel] / Opens the edit injuries window"), rather than requiring a manual scroll-to-"Edit
 * Injuries" step on the newly spawned unit - the same real limb-select -> injury-editor flow
 * DESIGN.md §5 "Selectable Injuries" describes, just opened automatically instead of waited on.
 *
 * Class/function names still say "RandomPatient" for historical reasons (renaming the Zeus module
 * class would orphan it in any mission that's already placed one) — the display name
 * ("Spawn Patient", zeus/config.cpp) no longer claims randomization.
 *
 * Split into two real gates, not one, same reasoning AFCM_SIM_ModuleMciSpawner's own function
 * documents for the same two-machine problem: `isServer` does the actual spawn (server-
 * authoritative, DESIGN.md §6) and remoteExecs the dialog-open to `owner _logic` - the real
 * client id of whichever machine is local to this module logic, i.e. the placing curator,
 * regardless of whether that's the same machine as the server. `local _logic` (true ONLY on that
 * same placing curator's own machine) is what then deletes the module logic itself so its icon
 * disappears once placed (on request, "the spawn patient module should disappear once placed") -
 * there's nothing left for the module object itself to do once the patient exists and its own
 * Edit Injuries dialog is open.
 *
 * Guards against firing more than once per placed module (`AFCM_SIM_moduleFired`, a variable
 * stashed on `_logic` itself) - vanilla Module_F's function has no guaranteed single-fire
 * behaviour (confirmed independently by ACE3's own Modules Framework docs, which built their own
 * wrapper specifically because "there is no guarantee" here), and re-firing would otherwise spawn
 * a duplicate patient silently.
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

if (isServer) then {
    private _casualtyType = _logic getVariable ["AFCM_SIM_casualtyType", afcm_sim_defaultCasualtyType];
    // Optional Session Name attribute (DESIGN.md § Spawn Sessions) - blank means
    // afcm_sim_spawner_fnc_spawnPatient auto-generates one ("Spawn Patient") as before.
    private _sessionLabel = _logic getVariable ["AFCM_SIM_sessionName", ""];
    private _ownerId = owner _logic;

    private _unit = [getPosASL _logic, [], _casualtyType, "", _sessionLabel] call afcm_sim_spawner_fnc_spawnPatient;

    // Same 1-tick delay afcm_sim_spawner_fnc_spawnPatient's own internal CBA_fnc_waitAndExecute
    // uses before wiring up the unit's scroll actions/applying injuries - opening the Injury
    // Author any earlier would load from a unit that isn't fully set up yet.
    [{
        params ["_unit", "_ownerId"];
        if (isNull _unit) exitWith {};
        [_unit] remoteExec ["afcm_sim_ui_fnc_injuryAuthor_open", _ownerId];
    }, [_unit, _ownerId], 1] call CBA_fnc_waitAndExecute;
};

if (local _logic) then {
    deleteVehicle _logic;
};
