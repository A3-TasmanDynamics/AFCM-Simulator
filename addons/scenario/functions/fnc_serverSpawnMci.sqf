/*
 * Author: Tasman Dynamics
 * Server-side handler for spawning a whole MCI (Mass Casualty Incident) - one patient per entry
 * in patientSpecs, each with its own independently-resolved injuries (fnc_resolveMciPatientSpec.sqf
 * - a real Preset's injuries, or a fresh random roll), at the given position. Called via remoteExec
 * from the MCI Creator dialog (afcm_sim_ui_fnc_mciCreator_onSpawn) - never spawns locally
 * (DESIGN.md §6).
 *
 * The whole incident shares one Spawn Session (DESIGN.md § Spawn Sessions,
 * afcm_sim_spawner_fnc_newSessionId) - one id generated up front, passed to every spawnPatient
 * call, so it can be deleted as a group later (Session Manager) without touching any other
 * session's patients - e.g. two medics each working their own MCI at once.
 *
 * Arguments:
 * 0: Position <ARRAY> - ASL/ATL, forwarded to afcm_sim_spawner_fnc_spawnPatient as-is
 * 1: Patient specs <ARRAY of STRING> - see fnc_getBuiltinMciPresets.sqf
 * 2: Casualty Type <NUMBER> (default 0) - same for every patient in this incident, see
 *    fnc_spawnPatient.sqf
 * 3: Session Name <STRING> (default "") - optional custom label for this Spawn Session, typed into
 *    the MCI Creator's Session Name field; blank falls back to the auto-generated label below.
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_pos", "_patientSpecs", ["_casualtyType", 0], ["_customLabel", ""]];

if !(isServer) exitWith {};
if (_patientSpecs isEqualTo []) exitWith {};

diag_log text format ["[AFCM-Simulator] serverSpawnMci - %1 patient(s) at %2, casualtyType=%3.", count _patientSpecs, _pos, _casualtyType];

private _sessionId = call afcm_sim_spawner_fnc_newSessionId;
private _sessionLabel = if (_customLabel isEqualTo "") then {
    format ["MCI Creator — %1 patients", count _patientSpecs]
} else {
    _customLabel
};

{
    private _injuries = [_x] call afcm_sim_scenario_fnc_resolveMciPatientSpec;
    [_pos, _injuries, _casualtyType, _sessionId, _sessionLabel] call afcm_sim_spawner_fnc_spawnPatient;
} forEach _patientSpecs;
