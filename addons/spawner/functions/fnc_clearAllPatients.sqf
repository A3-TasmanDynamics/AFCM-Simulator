/*
 * Author: Tasman Dynamics
 * Deletes EVERY patient spawned via afcm_sim_spawner_fnc_spawnPatient, across every Spawn Session,
 * and clears both tracking structures (AFCM_SIM_spawnedPatients and AFCM_SIM_spawnSessions).
 * Server-authoritative (DESIGN.md §6).
 *
 * Per-session-scoped clearing (clear only one Zeus/Eden batch or MCI, not everything - e.g. two
 * medics each working their own MCI at once) is real now: afcm_sim_spawner_fnc_serverDeleteSession
 * (DESIGN.md § Spawn Sessions), used by the Session Manager UI. This function stays as the
 * separate "wipe absolutely everything" action - the Session Manager's own "Clear All Sessions"
 * button calls this, behind a confirmation prompt (fnc_confirmDialog_open.sqf), since it's the
 * highest-blast-radius action in the mod.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

if !(isServer) exitWith {};

private _patients = missionNamespace getVariable ["AFCM_SIM_spawnedPatients", []];

{
    if (!isNull _x && { _x getVariable ["AFCM_SIM_isPatient", false] }) then {
        deleteVehicle _x;
    };
} forEach _patients;

AFCM_SIM_spawnedPatients = [];
publicVariable "AFCM_SIM_spawnedPatients";

AFCM_SIM_spawnSessions = [];
publicVariable "AFCM_SIM_spawnSessions";
