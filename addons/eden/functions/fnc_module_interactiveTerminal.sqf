/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleInteractiveTerminal (Eden, also Zeus-placeable via
 * scopeCurator=2) - displayName "Medical Terminal" now (renamed throughout the mod on request to
 * better explain what it is; this class/function name kept for historical reasons, same "don't
 * orphan an already-placed module" rule as AFCM_SIM_ModuleSpawnRandomPatient's own rename). Gives a
 * training scenario a diegetic way into the tool kit - sync this module to any placed object (a
 * Laptop_01_F, a table, anything) and every player gets two real addActions on it, "AFCM: Open MCI
 * Creator" / "AFCM: Open Session Manager" (afcm_sim_ui_fnc_addTerminalAction), instead of needing
 * the CBA keybind or Zeus itself.
 *
 * `owner _logic` is passed through to fnc_resolveTerminalTarget.sqf so it can remoteExec a real
 * hint back to the actual placing curator's client once resolution succeeds or fully fails
 * (on request - "gives a warning that it has to be placed on an object" / "add a hint if placed
 * onto an object that the object is now set as a terminal").
 *
 * Real, confirmed fix on request ("the module icon lingers for a while after it's placed not on an
 * object. Make it instant to disappear if possible"): this now runs `local _logic`-gated, not
 * isServer-gated - only the machine the module is actually local to (the placing curator, or the
 * server for an Eden-synced module resolved at mission start) can know IMMEDIATELY whether a real
 * attach/sync target exists; `attachedTo`/`_units` are authoritative without replication delay only
 * there. That confirmed yes/no is computed ONCE here and sent to the server alongside the resolve
 * request, so fnc_resolveTerminalTarget.sqf's own server-side retries (still needed for genuine
 * replication lag on a dedicated server) only actually happen when there's something real to wait
 * for - a standalone placement (confirmed locally as neither synced nor attached) deletes on the
 * very first attempt instead of waiting out the full ~5s retry window regardless.
 *
 * Target resolution supports both real placement paths: `_units` (synced units) is Eden's own
 * mechanism (Ctrl+click sync line, module to object) - checked first since that's the primary
 * design-time flow this module exists for. Falls back to `attachedTo _logic` if nothing was synced,
 * covering the Zeus "drag the module directly onto the object" path (curatorCanAttach=1,
 * eden/config.cpp) - same real mechanism AFCM_SIM_ModuleEditInjuries uses
 * (zeus/functions/fnc_module_editInjuries.sqf), grounded in ACE3's own Zeus module source.
 *
 * Real, confirmed gap fixed here: `attachedTo _logic` (the Zeus attach path specifically) isn't
 * guaranteed to have finished replicating to the server by the time this callback first runs on a
 * dedicated server - a curator dragging the module onto an object could see it silently never add
 * its actions. AFCM_SIM_moduleFired is also only latched AFTER a target actually resolves, not
 * before - so a genuine, still-unresolved case doesn't permanently block a later re-fire the way an
 * earlier pass did.
 *
 * Target resolution itself (with retry) is factored into fnc_resolveTerminalTarget.sqf, retrying
 * every 1s for up to 5 attempts rather than checking exactly once - a single fixed 1s defer (this
 * file's own earlier fix) still isn't a guaranteed-safe margin on every server (load, mission
 * complexity, a slower dedicated server all push replication further out), and silently giving up
 * after one attempt is exactly the "curator drags it on, nothing ever happens, no clue why" failure
 * mode being fixed here.
 *
 * Unlike Edit Injuries, this module doesn't self-delete or open anything itself - it's a persistent
 * placed effect ("this object is now a terminal"), so it guards against re-adding the same actions
 * on re-fire (`AFCM_SIM_moduleFired`), same pattern every other AFCM module here uses.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed/attached module
 * 1: Units <ARRAY> - synced units; first entry (if any) is the target object
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_logic", "_units", "_activated"];

diag_log text format ["[AFCM-Simulator][Eden][diag] Medical Terminal module fired - activated=%1, isServer=%2, local=%3.", _activated, isServer, local _logic];

if !(_activated) exitWith {};
if !(local _logic) exitWith {};
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};
_logic setVariable ["AFCM_SIM_moduleFired", true];

private _localTarget = _units param [0, objNull];
if (isNull _localTarget) then { _localTarget = attachedTo _logic; };

[_logic, _units, 1, owner _logic, !(isNull _localTarget)] remoteExec ["afcm_sim_eden_fnc_resolveTerminalTarget", 2];
