/*
 * Author: Tasman Dynamics
 * Spawns one patient unit at the given position and applies the given injuries to it via the
 * active backend (DESIGN.md §2.5). Server-authoritative (DESIGN.md §6) — clients should route
 * through this on the server, not call it locally.
 *
 * Injuries are applied after a short delay rather than immediately on createUnit — a real timing
 * requirement confirmed against a prior working prototype (REFERENCES.md): applying damage
 * immediately on creation doesn't reliably take before the unit's medical state has initialized.
 *
 * Arguments:
 * 0: Position <ARRAY> - ASL/ATL position to spawn at (jittered slightly)
 * 1: Injuries <ARRAY> - array of Injury <HASHMAP>, see DESIGN.md §4.2 (default [])
 *
 * Return Value:
 * Spawned unit <OBJECT>, or objNull if not run on the server
 *
 * Example:
 * [[0,0,0] getPos [], [1] call afcm_sim_scenario_fnc_randomizeInjuries] call afcm_sim_spawner_fnc_spawnPatient
 *
 * Public: Yes
*/

params ["_pos", ["_injuries", []]];

if !(isServer) exitWith { objNull };

if (isNil "AFCM_SIM_patientGroup") then {
    AFCM_SIM_patientGroup = createGroup [civilian, true];
};
if (isNil "AFCM_SIM_spawnedPatients") then {
    AFCM_SIM_spawnedPatients = [];
};

private _jitteredPos = [
    (_pos select 0) + (random 4 - 2),
    (_pos select 1) + (random 4 - 2),
    _pos param [2, 0]
];

private _unit = AFCM_SIM_patientGroup createUnit ["C_man_1", _jitteredPos, [], 0, "NONE"];
_unit setPosATL _jitteredPos;
_unit setUnitPos "DOWN";
_unit setCaptive true;
_unit setDir (random 360);
_unit setVariable ["AFCM_SIM_isPatient", true, true];

AFCM_SIM_spawnedPatients pushBack _unit;
publicVariable "AFCM_SIM_spawnedPatients";

[{
    params ["_unit", "_injuries"];
    if (isNull _unit) exitWith {};
    { [_unit, _x] call afcm_sim_fnc_backend_applyInjury; } forEach _injuries;
}, [_unit, _injuries], 1] call CBA_fnc_waitAndExecute;

_unit
