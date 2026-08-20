/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModulePatientPlacement (Eden). Reads the placed module's
 * AFCM_SIM_injuryLevel attribute and spawns a patient at its position on mission start
 * (DESIGN.md §5 "Map to Spawn Patients").
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

private _injuryLevel = _logic getVariable ["AFCM_SIM_injuryLevel", afcm_sim_defaultInjuryLevel];

[getPosASL _logic, _injuryLevel] call afcm_sim_spawner_fnc_spawnRandomPatient;
