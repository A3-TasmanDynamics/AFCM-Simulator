/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModulePatientPlacement (Eden). Injuries/casualty type/session label
 * resolution lives in afcm_sim_eden_fnc_resolvePatientAttributes.sqf now (Training Preset combo vs.
 * Injury Preset Import paste, see its own comment) - this file is just target/mode resolution.
 *
 * Two real modes, decided by whether an object resolves (real, confirmed behaviour change - syncing
 * used to only affect spawn POSITION, keeping auto-spawn-at-mission-start either way):
 *  - Nothing synced/attached (today's original default): auto-spawns immediately at mission start -
 *    one patient per marker matching AFCM_SIM_SpawnMarkerName as a PREFIX (eden/config.cpp), or one
 *    patient at this module's own placed position if that's blank/matches nothing.
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
        // Auto-spawn. Spawn Marker Name is a PREFIX, not one exact marker name (real, confirmed
        // request - a mission builder wants one module to seed a whole batch of casualties across a
        // training area, not place a separate module per patient) - every placed marker whose own
        // name starts with it (`find == 0`, `CBA_fnc_trim`'d first - Eden's text attribute can carry
        // stray leading/trailing whitespace from a paste) gets its own patient, all sharing this
        // module's same Casualty Type/Training Preset/Session Name. A single marker named EXACTLY the
        // prefix (no suffix) still matches on its own - `find` on an exact match is still 0 - so this
        // is backward compatible with the original "one marker, one patient" behaviour, just no
        // longer limited to it. Falls back to a single patient at the module's own placed position
        // when the prefix is blank or matches nothing (same as before this multi-marker support was
        // added).
        private _markerPrefix = (_logic getVariable ["AFCM_SIM_spawnMarkerName", ""]) call CBA_fnc_trim;
        private _matchingMarkers = if (_markerPrefix == "") then { [] } else {
            allMapMarkers select { (_x find _markerPrefix) == 0 }
        };

        (_logic call afcm_sim_eden_fnc_resolvePatientAttributes) params ["_injuries", "_casualtyType", "_sessionLabel", "_katExtras", "_patientName"];

        if (_matchingMarkers isEqualTo [] || {count _matchingMarkers == 1}) then {
            if (_markerPrefix != "" && {_matchingMarkers isEqualTo []}) then {
                diag_log text format ["[AFCM-Simulator] AFCM Patient module - Spawn Marker Name '%1' doesn't match any placed marker, falling back to the module's own position.", _markerPrefix];
            };
            private _pos = getPosASL _logic;
            if (count _matchingMarkers == 1) then {
                private _markerPos = getMarkerPos (_matchingMarkers select 0);
                _pos = [_markerPos select 0, _markerPos select 1, 0];
            };
            [_pos, _injuries, _casualtyType, "", _sessionLabel, _katExtras, -1, _patientName] call afcm_sim_spawner_fnc_spawnPatient;
        } else {
            // One shared session for the whole batch (same "generate one id up front, pass it to
            // every patient" pattern the MCI Spawner modules/MCI Creator already use) - so the whole
            // marker batch can be managed/deleted together in the Session Manager, not one session
            // per marker. A blank Session Name gets a batch-specific default instead of
            // fnc_spawnPatient.sqf's own generic "Spawn Patient" fallback, which only applies when NO
            // session id is passed at all - a real, pre-generated id here would otherwise reach the
            // Session Manager with a blank label.
            //
            // Patient Name is deliberately NOT threaded through here (config.cpp's own comment on
            // AFCM_SIM_PatientName) - every patient in a real multi-marker batch would otherwise share
            // this exact literal name, which is worse than the random pool it's meant to override.
            if (_patientName != "") then {
                diag_log text format ["[AFCM-Simulator] AFCM Patient module - Patient Name '%1' ignored: %2 markers matched, and a batch can't share one explicit name.", _patientName, count _matchingMarkers];
            };
            private _sessionId = call afcm_sim_spawner_fnc_newSessionId;
            if (_sessionLabel == "") then { _sessionLabel = "AFCM Patient (Marker Batch)"; };
            diag_log text format ["[AFCM-Simulator] AFCM Patient module - Spawn Marker Name '%1' matched %2 marker(s), spawning one patient at each.", _markerPrefix, count _matchingMarkers];
            {
                private _markerPos = getMarkerPos _x;
                private _pos = [_markerPos select 0, _markerPos select 1, 0];
                [_pos, _injuries, _casualtyType, _sessionId, _sessionLabel, _katExtras] call afcm_sim_spawner_fnc_spawnPatient;
            } forEach _matchingMarkers;
        };
    } else {
        // On-demand - don't spawn now. Position is resolved fresh at click time
        // (fnc_serverSpawnFromTerminal.sqf), not here, so a moved object still spawns correctly.
        _object setVariable ["AFCM_SIM_terminalSpawned", false, true];
        [_object, _logic] remoteExec ["afcm_sim_ui_fnc_addSpawnPatientAction", 0, true];
    };
}, [_logic, _units], 1] call CBA_fnc_waitAndExecute;
