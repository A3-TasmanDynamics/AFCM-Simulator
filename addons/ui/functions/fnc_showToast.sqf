/*
 * Author: Tasman Dynamics
 * Shows a generic, custom AFCM-branded toast - a passive, non-interactive overlay, not a dialog of
 * its own. Two real delivery paths, chosen per call:
 *  - No AFCM dialog open: RscDisplayAFCM_SIM_Toast (ui/config.cpp) via `cutRsc` - deliberately not
 *    createDialog-based, since a real interactive display would compete for input focus with (and
 *    could break) the Zeus interface or whatever else the viewer already has open - cutRsc's whole
 *    purpose is a non-modal layer that sits on top without stealing focus (real, confirmed vanilla
 *    mechanism - see the RscTitles class comment in config.cpp).
 *  - An AFCM dialog IS open: fnc_showToastOverlay.sqf instead - real, confirmed engine limitation
 *    fixed here (reported directly: Export with nothing staged showed its toast, but hidden behind
 *    the Injury Author dialog) - `cutRsc`/RscTitles layers always render BELOW any open
 *    `createDialog` display, hard-coded in the engine's own render order, not something a layer
 *    priority/index can override. Checks every real AFCM dialog IDD this addon owns (ui/config.cpp's
 *    own IDD_AFCM_SIM_* defines - hardcoded since #defines aren't available in SQF, same pattern
 *    every dialog's own onLoad handler already uses), "child/stacking" dialogs first (Confirm/Map
 *    Picker/Save Preset dialogs open ON TOP of a parent without closing it) so the toast lands on
 *    whichever one is actually topmost/visible.
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

private _openDisplay = objNull;
{
    private _d = findDisplay _x;
    if !(isNull _d) exitWith { _openDisplay = _d; };
} forEach [25610, 25606, 25604, 25608, 25611, 25605, 25603, 25607, 25609];

if !(isNull _openDisplay) exitWith {
    [_openDisplay, _title, _body] call afcm_sim_ui_fnc_showToastOverlay;
};

missionNamespace setVariable ["AFCM_SIM_UI_toastTitle", _title];
missionNamespace setVariable ["AFCM_SIM_UI_toastBody", _body];

// Fixed layer index - this is the only thing AFCM-Simulator ever shows via cutRsc, so a hardcoded
// constant is enough; no need for the extra BIS_fnc_rscLayer indirection just to avoid a collision
// that can't happen.
84750 cutRsc ["RscDisplayAFCM_SIM_Toast", "PLAIN"];
