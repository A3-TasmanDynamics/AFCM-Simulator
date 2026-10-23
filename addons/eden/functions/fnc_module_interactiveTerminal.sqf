/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleInteractiveTerminal (Eden, also Zeus-placeable via
 * scopeCurator=2). Gives a training scenario a diegetic way into the tool kit - sync this module to
 * any placed object (a Laptop_01_F, a table, anything) and every player gets two real addActions on
 * it, "AFCM: Open MCI Creator" / "AFCM: Open Session Manager" (afcm_sim_ui_fnc_addTerminalAction),
 * instead of needing the CBA keybind or Zeus itself.
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

diag_log text format ["[AFCM-Simulator][Eden][diag] Interactive Terminal module fired - activated=%1, isServer=%2, units=%3.", _activated, isServer, _units];

if !(_activated) exitWith {};
if !(isServer) exitWith {};
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};

[_logic, _units, 1] call afcm_sim_eden_fnc_resolveTerminalTarget;
