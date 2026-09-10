/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModulePatientPlacement (Eden). Injuries/casualty type/session label
 * resolution lives in afcm_sim_eden_fnc_resolvePatientAttributes.sqf now (Training Preset combo vs.
 * Injury Preset Import paste, see its own comment) - this file is just target/mode resolution.
 *
 * Two real modes, decided by whether an object resolves (real, confirmed behaviour change - syncing
 * used to only affect spawn POSITION, keeping auto-spawn-at-mission-start either way):
 *  - Nothing synced/attached (today's original default, unchanged): auto-spawns immediately at
 *    mission start, at the resolved marker-or-module position (AFCM_SIM_SpawnMarkerName,
 *    eden/config.cpp - unchanged logic, just moved inline below).
 *  - An object synced (Eden: Ctrl+click drag a sync line to it) or attached (Zeus drag-onto-object,
 *    same dual-resolution `_units` then `attachedTo _logic` pattern
 *    fnc_module_interactiveTerminal.sqf already uses - `attachedTo` is realistically unreachable here
 *    since this module is hidden from the Zeus curator browser, curatorCanAttach=0, included purely
 *    for defensive symmetry with that module's own pattern): does NOT auto-spawn. Instead adds a
 *    "Spawn Patient" interaction to that object (afcm_sim_ui_fnc_addSpawnPatientAction) which spawns
 *    this exact configured patient, at that object's own position, whenever a player uses it -
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
        // Auto-spawn, unchanged from before this module supported on-demand mode. Precedence: a
        // non-blank Spawn Marker Name that resolves to a real placed marker (`CBA_fnc_trim`'d first -
        // Eden's text attribute can carry stray leading/trailing whitespace from a paste, which would
        // otherwise silently fail the `markerType` lookup) -> that marker's position. Otherwise -> the
        // module's own placed position.
        private _markerName = (_logic getVariable ["AFCM_SIM_spawnMarkerName", ""]) call CBA_fnc_trim;
        private _pos = getPosASL _logic;
        if (_markerName != "") then {
            if (markerType _markerName != "") then {
                private _markerPos = getMarkerPos _markerName;
                _pos = [_markerPos select 0, _markerPos select 1, 0];
            } else {
                diag_log text format ["[AFCM-Simulator] AFCM Patient module - Spawn Marker Name '%1' doesn't match a placed marker, falling back to the module's own position.", _markerName];
            };
        };

        (_logic call afcm_sim_eden_fnc_resolvePatientAttributes) params ["_injuries", "_casualtyType", "_sessionLabel", "_katExtras"];
        [_pos, _injuries, _casualtyType, "", _sessionLabel, _katExtras] call afcm_sim_spawner_fnc_spawnPatient;
    } else {
        // On-demand - don't spawn now. Position is resolved fresh at click time
        // (fnc_serverSpawnFromTerminal.sqf), not here, so a moved object still spawns correctly.
        _object setVariable ["AFCM_SIM_terminalSpawned", false, true];
        [_object, _logic] remoteExec ["afcm_sim_ui_fnc_addSpawnPatientAction", 0, true];
    };
}, [_logic, _units], 1] call CBA_fnc_waitAndExecute;
