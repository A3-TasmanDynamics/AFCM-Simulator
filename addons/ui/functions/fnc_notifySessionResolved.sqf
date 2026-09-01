/*
 * Author: Tasman Dynamics
 * Client-side handler for a resolved Medical Tent session - run via remoteExec (target 0 = everyone)
 * from afcm_sim_scenario_fnc_startMedicalTentMonitor once every live patient in a Spawn Session is
 * both treated and on a stretcher. Publishes "session.resolved" on the local event bus
 * (afcm_sim_ui_fnc_publish, DESIGN.md §3 - same mechanism injury.applied/limb.selected already use,
 * so any future subscriber, e.g. a scoreboard, can hook in without AFCM needing to know about it),
 * then shows the actual notification via the generic toast helper.
 *
 * Arguments:
 * 0: Session id <STRING>
 * 1: Session label <STRING>
 * 2: Patient count <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_sessionId", "_sessionLabel", "_patientCount"];

["session.resolved", [_sessionId, _sessionLabel, _patientCount]] call afcm_sim_ui_fnc_publish;

[
    "AFCM: Medical Tent",
    format ["%1 — all %2 patient(s) treated and on a stretcher.", _sessionLabel, _patientCount]
] call afcm_sim_ui_fnc_showToast;
