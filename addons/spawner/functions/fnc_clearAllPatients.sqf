/*
 * Author: Tasman Dynamics
 * Deletes every patient spawned via afcm_sim_spawner_fnc_spawnPatient and clears the tracking
 * list. Server-authoritative (DESIGN.md §6).
 *
 * Per-spawner/session-scoped clearing (clear only what one Zeus module instance spawned, not
 * everything) is not implemented yet — this is a global "clear all" only, mirroring the simpler
 * half of the pattern confirmed in a prior working prototype (REFERENCES.md); worth revisiting if
 * MASCAL batches need independent cleanup.
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
