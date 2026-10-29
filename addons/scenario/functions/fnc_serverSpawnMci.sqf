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
 * 0: Position <ARRAY> - ASL/ATL, incident center
 * 1: Patient specs <ARRAY of STRING> - see fnc_getBuiltinMciPresets.sqf
 * 2: Casualty Type <NUMBER> (default 0) - same for every patient in this incident, see
 *    fnc_spawnPatient.sqf
 * 3: Session Name <STRING> (default "") - optional custom label for this Spawn Session, typed into
 *    the MCI Creator's Session Name field; blank falls back to the auto-generated label below.
 * 4: Radius <NUMBER> (default 10) - metres. Each patient gets its own independently-rolled
 *    position, uniformly distributed inside this circle around Position (real `sqrt(random 1) *
 *    radius` area-uniform disk sampling, not just a random angle at a fixed distance, which would
 *    cluster patients near the circle's edge instead). Passes _exactPos=true to
 *    afcm_sim_spawner_fnc_spawnPatient so its own small built-in +/-2m box jitter doesn't ALSO stack
 *    on top of this (on request - "set a radius of the patients spawning").
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_pos", "_patientSpecs", ["_casualtyType", 0], ["_customLabel", ""], ["_radius", 10]];

if !(isServer) exitWith {};
if (_patientSpecs isEqualTo []) exitWith {};

diag_log text format ["[AFCM-Simulator] serverSpawnMci - %1 patient(s) at %2, casualtyType=%3, radius=%4.", count _patientSpecs, _pos, _casualtyType, _radius];

private _sessionId = call afcm_sim_spawner_fnc_newSessionId;
private _sessionLabel = if (_customLabel isEqualTo "") then {
    format ["MCI Creator — %1 patients", count _patientSpecs]
} else {
    _customLabel
};

{
    private _injuries = [_x] call afcm_sim_scenario_fnc_resolveMciPatientSpec;
    private _angle = random 360;
    private _dist = sqrt (random 1) * _radius;
    private _scatterPos = [
        (_pos select 0) + _dist * sin _angle,
        (_pos select 1) + _dist * cos _angle,
        _pos select 2
    ];
    [_scatterPos, _injuries, _casualtyType, _sessionId, _sessionLabel, [], -1, true] call afcm_sim_spawner_fnc_spawnPatient;
} forEach _patientSpecs;
