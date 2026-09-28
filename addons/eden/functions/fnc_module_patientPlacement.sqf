/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModulePatientPlacement (Eden). Injuries/casualty type/session label
 * resolution lives in afcm_sim_eden_fnc_resolvePatientAttributes.sqf now (Training Preset combo vs.
 * Injury Preset Import paste, see its own comment) - this file is just target/mode resolution.
 *
 * Two real modes, decided by whether an object resolves. Both spawn according to the SAME marker
 * precedence (fnc_serverSpawnForLogic.sqf, shared by both) - real, confirmed fix: syncing an object
 * used to mean "spawn at that object's position, Spawn Marker Name ignored entirely" even if markers
 * were configured, so a module set up to seed a training area AND synced to a laptop for on-demand
 * triggering silently spawned one patient at the laptop instead of the whole configured scenario:
 *  - Nothing synced/attached (today's original default): auto-spawns immediately at mission start -
 *    one patient per marker named in AFCM_SIM_SpawnMarkerName's comma-separated list (eden/
 *    config.cpp), or one patient at this module's own placed position if that's blank/none resolve.
 *  - An object synced (Eden: Ctrl+click drag a sync line to it) or attached (Zeus drag-onto-object,
 *    same dual-resolution `_units` then `attachedTo _logic` pattern
 *    fnc_module_interactiveTerminal.sqf already uses - `attachedTo` is realistically unreachable here
 *    since this module is hidden from the Zeus curator browser, curatorCanAttach=0, included purely
 *    for defensive symmetry with that module's own pattern): does NOT auto-spawn. Instead adds a
 *    "Spawn Patient" interaction to that object (afcm_sim_ui_fnc_addSpawnPatientAction), repeatable
 *    for as long as the scenario needs - each use spawns one patient per configured marker (or one at
 *    the object's own position, only when Spawn Marker Name is blank/nothing resolves) -
 *    afcm_sim_eden_fnc_serverSpawnFromTerminal does the actual spawn once that fires.
 *
 * Same 1s-deferred resolution fnc_module_interactiveTerminal.sqf uses and documents - a real,
 * confirmed-necessary delay: a Zeus-attached object's replication isn't guaranteed to have reached
 * the server yet the instant this callback first runs.
 *
 * Guards against firing more than once per placed module (`AFCM_SIM_moduleFired`, a variable
 * stashed on `_logic` itself) - vanilla Module_F's function has no guaranteed single-fire
 * behaviour (confirmed independently by ACE3's own Modules Framework docs, which built their own
 * wrapper specifically because "there is no guarantee" here), and re-firing would otherwise spawn
 * a duplicate patient, or re-add the Spawn Patient interaction a second time, silently.
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

if !(_activated) exitWith {};
if !(isServer) exitWith {};
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};

[{
    params ["_logic", "_units"];
    if (isNull _logic) exitWith {};
    _logic setVariable ["AFCM_SIM_moduleFired", true];

    private _object = _units param [0, objNull];
    if (isNull _object) then { _object = attachedTo _logic; };

    if (isNull _object) then {
        // Auto-spawn - real spawn/marker-resolution logic now shared with the on-demand path
        // (fnc_serverSpawnForLogic.sqf's own comment has the full "why a shared function" reasoning).
        [_logic, getPosASL _logic] call afcm_sim_eden_fnc_serverSpawnForLogic;
    } else {
        // On-demand - don't spawn now. Position is resolved fresh at click time
        // (fnc_serverSpawnFromTerminal.sqf), not here, so a moved object still spawns correctly.
        _object setVariable ["AFCM_SIM_terminalSpawned", false, true];
        [_object, _logic] remoteExec ["afcm_sim_ui_fnc_addSpawnPatientAction", 0, true];
    };
}, [_logic, _units], 1] call CBA_fnc_waitAndExecute;
