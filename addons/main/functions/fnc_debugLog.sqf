/*
 * Author: Tasman Dynamics
 * Logs a message only if the "Debug Logging" Addon Option (afcm_sim_debugLogging) is enabled.
 * Use this for verbose/routine diagnostic output (backend registration, selection, dispatch
 * failures); leave plain diag_log for things that should always be visible (e.g. a stub function
 * being called at all, which is a "this isn't built yet" notice, not log noise).
 *
 * Arguments:
 * 0: Message <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_message"];

if (afcm_sim_debugLogging) then {
    diag_log text _message;
};
