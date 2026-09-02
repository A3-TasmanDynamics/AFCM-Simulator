/*
 * Author: Tasman Dynamics
 * Generates a fresh, unique Spawn Session id (DESIGN.md § Spawn Sessions) - same scheme
 * afcm_sim_spawner_fnc_spawnPatient uses internally when no session id is given, factored out here
 * so batch spawners (MCI Spawner modules, MASCAL Zone, the MCI Creator) can generate ONE id up
 * front and pass the same one to every patient in their loop, landing the whole batch in one
 * session instead of one session per patient.
 *
 * Real, confirmed collision fixed here: `diag_tickTime` + `random 100000` alone had a real, if
 * small, chance of two batch spawns landing in the same server tick generating the identical id -
 * a collision would silently merge two unrelated incidents into one AFCM_SIM_spawnSessions entry
 * (fnc_spawnPatient.sqf finds the "existing" index and appends rather than creating a new one), so
 * deleting one session would also delete the other's patients. A simple, always-incrementing
 * counter guarantees no collision is possible at all, regardless of timing - two calls in the same
 * frame still get different values, since SQF itself is single-threaded per scheduler tick.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Session id <STRING>
 *
 * Public: Yes
*/

if (isNil "AFCM_SIM_sessionIdCounter") then { AFCM_SIM_sessionIdCounter = 0; };
AFCM_SIM_sessionIdCounter = AFCM_SIM_sessionIdCounter + 1;

format ["session_%1_%2", diag_tickTime, AFCM_SIM_sessionIdCounter]
