/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleMascalZone (Eden). Reads the placed module's
 * AFCM_SIM_patientCount, AFCM_SIM_injuryLevel, and AFCM_SIM_casualtyType attributes and spawns that
 * many patients around its position on mission start (DESIGN.md §5 "Map to Spawn Patients...
 * MASCAL scenarios").
 *
 * Each patient is spawned via afcm_sim_spawner_fnc_spawnRandomPatient, which jitters position by
 * ±2m per call — with multiple patients at the same base position that gives a natural loose
 * scatter. No dedicated zone-radius attribute yet; worth revisiting if a tighter/looser spread
 * needs to be mission-maker-configurable later.
 *
 * The whole batch shares one Spawn Session (DESIGN.md § Spawn Sessions) - one id generated up
 * front, passed to every spawnRandomPatient call, so it can be deleted as a group later without
 * touching any other session's patients.
 *
 * Guards against firing more than once per placed module (`AFCM_SIM_moduleFired`, a variable
 * stashed on `_logic` itself) - vanilla Module_F's function has no guaranteed single-fire
 * behaviour (confirmed independently by ACE3's own Modules Framework docs, which built their own
 * wrapper specifically because "there is no guarantee" here), and re-firing would otherwise spawn
 * a duplicate batch silently.
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

private _patientCount = _logic getVariable ["AFCM_SIM_patientCount", 4];
private _injuryLevel = _logic getVariable ["AFCM_SIM_injuryLevel", afcm_sim_defaultInjuryLevel];
private _casualtyType = _logic getVariable ["AFCM_SIM_casualtyType", afcm_sim_defaultCasualtyType];
private _pos = getPosASL _logic;

private _sessionId = call afcm_sim_spawner_fnc_newSessionId;
private _sessionLabel = format ["AFCM MASCAL Zone — %1 patients", _patientCount];

for "_i" from 1 to _patientCount do {
    [_pos, _injuryLevel, _casualtyType, _sessionId, _sessionLabel] call afcm_sim_spawner_fnc_spawnRandomPatient;
};
