/*
 * Author: Tasman Dynamics
 * Server-side handler for spawning a whole MCI (Mass Casualty Incident) - one patient per entry
 * in patientSpecs, each with its own independently-resolved injuries (fnc_resolveMciPatientSpec.sqf
 * - a real Preset's injuries, or a fresh random roll), at the given position. Called via remoteExec
 * from the MCI Creator dialog (afcm_sim_ui_fnc_mciCreator_onSpawn) - never spawns locally
 * (DESIGN.md §6).
 *
 * Arguments:
 * 0: Position <ARRAY> - ASL/ATL, forwarded to afcm_sim_spawner_fnc_spawnPatient as-is
 * 1: Patient specs <ARRAY of STRING> - see fnc_getBuiltinMciPresets.sqf
 * 2: Casualty Type <NUMBER> (default 0) - same for every patient in this incident, see
 *    fnc_spawnPatient.sqf
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_pos", "_patientSpecs", ["_casualtyType", 0]];

if !(isServer) exitWith {};
if (_patientSpecs isEqualTo []) exitWith {};

diag_log text format ["[AFCM-Simulator] serverSpawnMci - %1 patient(s) at %2, casualtyType=%3.", count _patientSpecs, _pos, _casualtyType];

{
    private _injuries = [_x] call afcm_sim_scenario_fnc_resolveMciPatientSpec;
    [_pos, _injuries, _casualtyType] call afcm_sim_spawner_fnc_spawnPatient;
} forEach _patientSpecs;
