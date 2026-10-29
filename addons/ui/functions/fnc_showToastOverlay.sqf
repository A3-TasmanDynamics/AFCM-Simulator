/*
 * Author: Tasman Dynamics
 * Real fix for toasts rendering invisibly behind an open AFCM dialog (on request - reported
 * directly: clicking Export in the Injury Author with nothing staged shows "Nothing staged to
 * export yet.", but it's hidden behind the dialog). Real, confirmed engine limitation: `cutRsc`/
 * `RscTitles` HUD layers always render BELOW any open `createDialog` display - this is hard-coded
 * render order in the engine itself, not something a layer priority/index can override. Called by
 * fnc_showToast.sqf instead of `cutRsc` whenever one of AFCM's own dialogs is currently open.
 *
 * Builds the toast as real transient controls `ctrlCreate`d directly onto the already-open display
 * (so they're genuinely part of its own control list, guaranteed to render above everything else
 * already on it) rather than a separate layer - reuses the exact same base theme classes
 * RscDisplayAFCM_SIM_Toast's own controls use (AFCM_SIM_Panel/AFCM_SIM_AccentBar/AFCM_SIM_RscTitle/
 * AFCM_SIM_RscLabel, ui/config.cpp), with the same position/size/color values applied via script
 * since ctrlCreate only takes a plain top-level class name, not those nested per-instance
 * overrides. Self-deletes after a fixed delay - no fade in/out (cutRsc's own `fadeIn`/`fadeOut` are
 * a dialog-layer-only feature, not available on a plain control), but still clearly visible for
 * the same real ~5s window.
 *
 * Arguments:
 * 0: Target display <DISPLAY> - an already-open AFCM dialog
 * 1: Title <STRING>
 * 2: Body <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display", "_title", "_body"];

if (isNull _display) exitWith {};

private _panel = _display ctrlCreate ["AFCM_SIM_Panel", -1];
_panel ctrlSetPosition [0.32 * safeZoneW + safeZoneX, 0.06 * safeZoneH + safeZoneY, 0.36 * safeZoneW, 0.09 * safeZoneH];
_panel ctrlCommit 0;

private _bar = _display ctrlCreate ["AFCM_SIM_AccentBar", -1];
_bar ctrlSetPosition [0.32 * safeZoneW + safeZoneX, 0.06 * safeZoneH + safeZoneY, 0.36 * safeZoneW, 0.0025 * safeZoneH];
_bar ctrlCommit 0;

private _ctrlTitle = _display ctrlCreate ["AFCM_SIM_RscTitle", -1];
_ctrlTitle ctrlSetPosition [0.335 * safeZoneW + safeZoneX, 0.0725 * safeZoneH + safeZoneY, 0.35 * safeZoneW, 0.03 * safeZoneH];
_ctrlTitle ctrlSetFontHeight (0.022 * safeZoneH);
_ctrlTitle ctrlSetText _title;
_ctrlTitle ctrlCommit 0;

private _ctrlBody = _display ctrlCreate ["AFCM_SIM_RscLabel", -1];
_ctrlBody ctrlSetPosition [0.335 * safeZoneW + safeZoneX, 0.1025 * safeZoneH + safeZoneY, 0.35 * safeZoneW, 0.04 * safeZoneH];
_ctrlBody ctrlSetFontHeight (0.018 * safeZoneH);
_ctrlBody ctrlSetTextColor [0.75, 0.72, 0.68, 1];
_ctrlBody ctrlSetText _body;
_ctrlBody ctrlCommit 0;

[{
    params ["_ctrls"];
    { if !(isNull _x) then { ctrlDelete _x; }; } forEach _ctrls;
}, [[_panel, _bar, _ctrlTitle, _ctrlBody]], 5] call CBA_fnc_waitAndExecute;
