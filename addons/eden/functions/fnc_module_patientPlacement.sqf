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
 * Guards against firing more than once per placed module (`AFCM_SIM_moduleFired`, a variable
 * stashed on `_logic` itself) - vanilla Module_F's function has no guaranteed single-fire
 * behaviour (confirmed independently by ACE3's own Modules Framework docs, which built their own
 * wrapper specifically because "there is no guarantee" here), and re-firing would otherwise spawn
 * a duplicate patient silently.
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
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};
_logic setVariable ["AFCM_SIM_moduleFired", true];

private _casualtyType = _logic getVariable ["AFCM_SIM_casualtyType", afcm_sim_defaultCasualtyType];
// Optional Session Name attribute (DESIGN.md § Spawn Sessions) - blank means
// afcm_sim_spawner_fnc_spawnPatient auto-generates one ("Spawn Patient") as before.
private _sessionLabel = _logic getVariable ["AFCM_SIM_sessionName", ""];

[getPosASL _logic, [], _casualtyType, "", _sessionLabel] call afcm_sim_spawner_fnc_spawnPatient;
