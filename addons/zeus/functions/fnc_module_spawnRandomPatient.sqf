/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleSpawnRandomPatient (Zeus). Spawns a patient with a
 * randomized identity/loadout and randomized injury set at the module's placement position
 * (DESIGN.md §5 "Random Patient"), via afcm_sim_spawner. Injury level comes from the
 * afcm_sim_defaultInjuryLevel Addon Option (no per-module attribute for level yet).
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

[getPosASL _logic, afcm_sim_defaultInjuryLevel] call afcm_sim_spawner_fnc_spawnRandomPatient;
