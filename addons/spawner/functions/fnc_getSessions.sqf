/*
 * Author: Tasman Dynamics
 * Returns every active Spawn Session (DESIGN.md § Spawn Sessions) - safe to call from any machine,
 * since `AFCM_SIM_spawnSessions` is `publicVariable`d by the server on every change
 * (afcm_sim_spawner_fnc_spawnPatient/serverDeleteSession/clearAllPatients), same real, already-
 * proven sync pattern `AFCM_SIM_spawnedPatients` already uses.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Sessions <ARRAY> - each `[id <STRING>, label <STRING>, spawnTime <NUMBER>, units <ARRAY of OBJECT>]`
 *
 * Public: Yes
*/

missionNamespace getVariable ["AFCM_SIM_spawnSessions", []]
