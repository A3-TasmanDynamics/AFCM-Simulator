/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModulePatientPlacement (Eden). Should read the placed module's
 * AFCM_SIM_injuryLevel attribute and spawn/configure a patient at its position on mission start
 * (DESIGN.md §5 "Map to Spawn Patients").
 *
 * TODO — not yet implemented. afcm_sim_spawner has no real spawning logic yet (still a config-
 * only stub); this is a logging stub so the module is placeable and its attribute is readable/
 * testable in Eden now, without pretending to actually spawn anything until the spawner is built.
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

private _injuryLevel = _logic getVariable ["AFCM_SIM_injuryLevel", 0];

diag_log text format ["[AFCM-Simulator][Eden] Patient Placement module activated at %1, injuryLevel=%2 - not yet implemented, see fnc_module_patientPlacement.sqf TODO.", getPosASL _logic, _injuryLevel];
