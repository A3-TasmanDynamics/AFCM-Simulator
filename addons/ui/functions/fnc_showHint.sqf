/*
 * Author: Tasman Dynamics
 * Thin wrapper around the real vanilla `hint` command - exists purely so server-side code can
 * remoteExec a plain hint by function name (remoteExec needs a real compiled function, not an
 * arbitrary engine command string) the same way every other client-local UI helper in this addon
 * is reached. Used where a full AFCM-branded toast (fnc_showToast.sqf) is more than the message
 * needs - on request, "change the medical terminal set successfully [message] to a hint... can be
 * changed to a hint rather than the large popup window".
 *
 * Arguments:
 * 0: Text <STRING>
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_text"];

hint _text;
