/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleSpawnRandomPatient (Zeus). Spawns a clean, unconscious
 * patient at the module's placement position — no randomized injuries anymore. Injuries are
 * selected afterward via the "Edit Injuries" scroll action every spawned patient gets
 * (afcm_sim_ui_fnc_addInjuryEditorAction, wired up inside afcm_sim_spawner_fnc_spawnPatient
 * itself), the same real limb-select -> injury-editor flow DESIGN.md §5 "Selectable Injuries"
 * describes. This gives the Zeus operator actual control over what's wrong with the patient
 * instead of a random roll — matching the explicit ask that patients should just spawn, with
 * injuries chosen by hand, not auto-applied.
 *
 * Class/function names still say "RandomPatient" for historical reasons (renaming the Zeus module
 * class would orphan it in any mission that's already placed one) — the display name
 * ("Spawn Patient", zeus/config.cpp) no longer claims randomization.
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
