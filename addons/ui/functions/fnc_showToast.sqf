/*
 * Author: Tasman Dynamics
 * Shows a generic, custom AFCM-branded toast (RscDisplayAFCM_SIM_Toast, ui/config.cpp) - a
 * passive, non-interactive HUD overlay, not a dialog. Deliberately not createDialog-based, since a
 * real interactive display would compete for input focus with (and could break) the Zeus interface
 * or whatever else the viewer already has open - cutRsc's whole purpose is a non-modal layer that
 * sits on top without stealing focus (real, confirmed vanilla mechanism - see the RscTitles class
 * comment in config.cpp).
 *
 * Runs entirely on the calling machine - callers that need every client to see it (e.g. a
 * server-detected event) remoteExec this by name, same as every other client-local UI helper in
 * this addon (addAction handlers, etc.).
 *
 * Arguments:
 * 0: Title <STRING>
 * 1: Body <STRING> (default "")
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_title", ["_body", ""]];

missionNamespace setVariable ["AFCM_SIM_UI_toastTitle", _title];
missionNamespace setVariable ["AFCM_SIM_UI_toastBody", _body];

// Fixed layer index - this is the only thing AFCM-Simulator ever shows via cutRsc, so a hardcoded
// constant is enough; no need for the extra BIS_fnc_rscLayer indirection just to avoid a collision
// that can't happen.
84750 cutRsc ["RscDisplayAFCM_SIM_Toast", "PLAIN"];
