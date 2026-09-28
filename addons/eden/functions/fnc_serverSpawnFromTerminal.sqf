/*
 * Author: Tasman Dynamics
 * Server-side handler for an AFCM Patient module's on-demand "Spawn Patient" interaction
 * (fnc_module_patientPlacement.sqf's on-demand branch, afcm_sim_ui_fnc_addSpawnPatientAction) -
 * remoteExec'd to target 2 (server) from whichever client's screen the interaction was actually used
 * on, same "always route through the server" convention afcm_sim_spawner_fnc_spawnPatient's own
 * docstring documents and fnc_addTreatedAction.sqf/fnc_mciCreator_onSpawn.sqf already follow.
 *
 * Repeatable by design (real, confirmed request) - the interaction is meant to keep spawning fresh
 * patients from the same synced object for as long as the scenario needs, not just once. Guarded
 * against a genuine DOUBLE-fire from one single click (two players triggering it in the same instant,
 * or the client-side click somehow reaching the server twice) via a short-lived debounce on
 * `AFCM_SIM_terminalSpawned` (init'd false by fnc_module_patientPlacement.sqf when the interaction is
 * first added) - an atomic check-and-set, safe because SQF is single-threaded and nothing here yields
 * between the check and the set, so a second call arriving in the same or a later frame within the
 * debounce window always sees the flag already true. The flag then clears itself 2 seconds later, well
 * past any realistic double-fire window, re-arming the interaction for the next real spawn. The
 * interaction's own `condition` string (fnc_addSpawnPatientAction.sqf) also hides it client-side while
 * the debounce is active, but that's a UX nicety, not what actually prevents a double-spawn - this
 * check is.
 *
 * Position is resolved fresh here (`getPosASL _object`), not pre-computed when the interaction was
 * added, so a synced object that moves between mission start and someone actually using it still
 * spawns the patient at its current position. Jitter is kept (Exact Position left at its default
 * false, unlike the Eden module's own marker-based auto-spawn - fnc_module_patientPlacement.sqf) -
 * deliberately, since repeat spawns from this same interaction would otherwise stack directly on top
 * of each other and any prior patients still standing there.
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
[{
    params ["_object"];
    if (isNull _object) exitWith {};
    _object setVariable ["AFCM_SIM_terminalSpawned", false, true];
}, [_object], 2] call CBA_fnc_waitAndExecute;

private _pos = getPosASL _object;
(_logic call afcm_sim_eden_fnc_resolvePatientAttributes) params ["_injuries", "_casualtyType", "_sessionLabel", "_katExtras"];
[_pos, _injuries, _casualtyType, "", _sessionLabel, _katExtras] call afcm_sim_spawner_fnc_spawnPatient;
