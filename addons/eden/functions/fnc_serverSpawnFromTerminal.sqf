/*
 * Author: Tasman Dynamics
 * Server-side handler for an AFCM Patient module's on-demand "Spawn Patient" interaction
 * (fnc_module_patientPlacement.sqf's on-demand branch, afcm_sim_ui_fnc_addSpawnPatientAction) -
 * remoteExec'd to target 2 (server) from whichever client's screen the interaction was actually used
 * on, same "always route through the server" convention afcm_sim_spawner_fnc_spawnPatient's own
 * docstring documents and fnc_addTreatedAction.sqf/fnc_mciCreator_onSpawn.sqf already follow.
 *
 * Guarded against spawning twice if two players trigger the interaction around the same time - an
 * atomic check-and-set on `AFCM_SIM_terminalSpawned` (init'd false by
 * fnc_module_patientPlacement.sqf when the interaction is first added). Safe because SQF is
 * single-threaded and nothing here yields between the check and the set, so a second call arriving in
 * the same or a later frame always sees the flag already true - same reasoning as every
 * `AFCM_SIM_moduleFired` guard elsewhere in this addon. The interaction's own `condition` string
 * (fnc_addSpawnPatientAction.sqf) also hides it client-side once set, but that's a UX nicety, not
 * what actually prevents a double-spawn - this check is.
 *
 * Position is resolved fresh here (`getPosASL _object`), not pre-computed when the interaction was
 * added, so a synced object that moves between mission start and someone actually using it still
 * spawns the patient at its current position.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed AFCM_SIM_ModulePatientPlacement module
 * 1: Object <OBJECT> - whatever it was synced/attached to
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_logic", "_object"];

if !(isServer) exitWith {};
if (isNull _logic || {isNull _object}) exitWith {};
if (_object getVariable ["AFCM_SIM_terminalSpawned", false]) exitWith {};
_object setVariable ["AFCM_SIM_terminalSpawned", true, true];

private _pos = getPosASL _object;
(_logic call afcm_sim_eden_fnc_resolvePatientAttributes) params ["_injuries", "_casualtyType", "_sessionLabel", "_katExtras"];
[_pos, _injuries, _casualtyType, "", _sessionLabel, _katExtras] call afcm_sim_spawner_fnc_spawnPatient;
