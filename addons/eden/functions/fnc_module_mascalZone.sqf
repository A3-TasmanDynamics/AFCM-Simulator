/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleMascalZone (Eden). Reads the placed module's
 * AFCM_SIM_patientCount and AFCM_SIM_injuryLevel attributes and spawns that many patients around
 * its position on mission start (DESIGN.md §5 "Map to Spawn Patients... MASCAL scenarios").
 *
 * Each patient is spawned via afcm_sim_spawner_fnc_spawnRandomPatient, which jitters position by
 * ±2m per call — with multiple patients at the same base position that gives a natural loose
 * scatter. No dedicated zone-radius attribute yet; worth revisiting if a tighter/looser spread
 * needs to be mission-maker-configurable later.
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

private _patientCount = _logic getVariable ["AFCM_SIM_patientCount", 4];
private _injuryLevel = _logic getVariable ["AFCM_SIM_injuryLevel", afcm_sim_defaultInjuryLevel];
private _pos = getPosASL _logic;

for "_i" from 1 to _patientCount do {
    [_pos, _injuryLevel] call afcm_sim_spawner_fnc_spawnRandomPatient;
};
