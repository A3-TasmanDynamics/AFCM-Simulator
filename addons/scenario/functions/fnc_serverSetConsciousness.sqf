/*
 * Author: Tasman Dynamics
 * Server-side handler for the Injury Author dialog's "Wake Up"/"Knock Out" toggle (edit mode only -
 * DESIGN.md §5 "Selectable Injuries"). Called via remoteExec from afcm_sim_ui, never called directly
 * by a client - DESIGN.md §6 requires interventions to be requests validated and applied on the
 * server, same pattern as fnc_serverSetVitals.sqf/fnc_serverReset.sqf.
 *
 * AFCM_SIM_allowConscious is the real fix here, not just a label - fnc_spawnPatient.sqf's own
 * recurring 3s safeguard loop unconditionally re-locks every patient unconscious, specifically to
 * stop them "healing themselves" by spontaneously waking. Without an explicit opt-out that loop
 * would silently undo a deliberate "Wake Up" within 3 seconds. Set back to false whenever this is
 * used to knock the patient back out, so the safeguard resumes normally - an instructor manually
 * waking a patient doesn't mean every FUTURE unconsciousness request on that same unit should also
 * be ignored forever.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Unconscious <BOOL> - true to knock out, false to wake up
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_unit", "_unconscious"];

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};

_unit setVariable ["AFCM_SIM_allowConscious", !_unconscious, true];
[_unit, _unconscious] call afcm_sim_fnc_backend_setUnconscious;
