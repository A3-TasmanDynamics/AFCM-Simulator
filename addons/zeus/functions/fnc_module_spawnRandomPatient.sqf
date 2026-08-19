/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleSpawnRandomPatient (Zeus). Should spawn a patient with a
 * randomized identity/loadout and randomized injury set at the module's placement position
 * (DESIGN.md §5 "Random Patient"), via afcm_sim_spawner.
 *
 * TODO — not yet implemented. afcm_sim_spawner has no real spawning logic yet (still a config-
 * only stub); this is a logging stub so the module is placeable and testable in Zeus now, without
 * pretending to actually spawn anything until the spawner is built.
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

diag_log text format ["[AFCM-Simulator][Zeus] Spawn Random Patient module activated at %1 - not yet implemented, see fnc_module_spawnRandomPatient.sqf TODO.", getPosASL _logic];
