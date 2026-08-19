/*
 * Author: Tasman Dynamics
 * Returns the currently active backend id, as selected by the server (DESIGN.md §2.5/§6).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Backend id <STRING> - "afcm", "ace", or "" if none is active
 *
 * Public: Yes
*/

missionNamespace getVariable ["AFCM_SIM_activeBackend", ""]
