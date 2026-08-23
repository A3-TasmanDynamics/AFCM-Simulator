/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModulePatientPlacement (Eden). Spawns a clean, unconscious patient
 * at the module's position on mission start — no randomized injuries anymore (the module's old
 * AFCM_SIM_injuryLevel attribute is gone, eden/config.cpp). Injuries are selected afterward via
 * the "Edit Injuries" scroll action every spawned patient gets
 * (afcm_sim_ui_fnc_addInjuryEditorAction, wired up inside afcm_sim_spawner_fnc_spawnPatient
 * itself) — the same real limb-select -> injury-editor flow DESIGN.md §5 "Selectable Injuries"
 * describes, now required even for Eden-placed patients, not just Zeus-spawned ones.
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

[getPosASL _logic] call afcm_sim_spawner_fnc_spawnPatient;
