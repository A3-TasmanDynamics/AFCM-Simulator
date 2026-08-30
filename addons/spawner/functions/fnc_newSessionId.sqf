/*
 * Author: Tasman Dynamics
 * Generates a fresh, unique Spawn Session id (DESIGN.md § Spawn Sessions) - same scheme
 * afcm_sim_spawner_fnc_spawnPatient uses internally when no session id is given, factored out here
 * so batch spawners (MCI Spawner modules, MASCAL Zone, the MCI Creator) can generate ONE id up
 * front and pass the same one to every patient in their loop, landing the whole batch in one
 * session instead of one session per patient.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Session id <STRING>
 *
 * Public: Yes
*/

format ["session_%1_%2", diag_tickTime, floor (random 100000)]
