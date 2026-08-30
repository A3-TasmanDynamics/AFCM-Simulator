/*
 * Author: Tasman Dynamics
 * Convenience wrapper for DESIGN.md §5 "Random Patient": rolls a randomized injury set for the
 * given level (afcm_sim_scenario_fnc_randomizeInjuries) and spawns a patient with it
 * (afcm_sim_spawner_fnc_spawnPatient) in one action.
 *
 * Arguments:
 * 0: Position <ARRAY>
 * 1: Injury level <NUMBER> - 0=Easy .. 4=F*CKED!, default 1 (Medium)
 * 2: Casualty Type <NUMBER> - 0=Civilian, 1=Military (BLUFOR), 2=Military (OPFOR),
 *    3=Military (Independent), see fnc_spawnPatient.sqf (default 0)
 *
 * Return Value:
 * Spawned unit <OBJECT>, or objNull if not run on the server
 *
 * Public: Yes
*/

params ["_pos", ["_injuryLevel", 1], ["_casualtyType", 0]];

private _injuries = [_injuryLevel] call afcm_sim_scenario_fnc_randomizeInjuries;

[_pos, _injuries, _casualtyType] call afcm_sim_spawner_fnc_spawnPatient
