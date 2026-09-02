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
 * its actions. Deferred 1s before resolving the target, same reasoning as afcm_sim_spawner_fnc_
 * spawnPatient's own addAction registration (a freshly-attached/created object's state isn't
 * guaranteed to have replicated to every machine yet). AFCM_SIM_moduleFired is also only latched
 * AFTER a target actually resolves, not before - so a genuine, still-unresolved case doesn't
 * permanently block a later re-fire the way an earlier pass did.
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

if !(_activated) exitWith {};
if !(isServer) exitWith {};
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};

[{
    params ["_logic", "_units"];
    if (isNull _logic) exitWith {};

    private _object = _units param [0, objNull];
    if (isNull _object) then { _object = attachedTo _logic; };

    if (isNull _object) exitWith {
        diag_log text "[AFCM-Simulator][Eden] Interactive Terminal module fired with no synced/attached object - nothing to add actions to.";
    };

    _logic setVariable ["AFCM_SIM_moduleFired", true];
    [_object] remoteExec ["afcm_sim_ui_fnc_addTerminalAction", 0, true];
}, [_logic, _units], 1] call CBA_fnc_waitAndExecute;
