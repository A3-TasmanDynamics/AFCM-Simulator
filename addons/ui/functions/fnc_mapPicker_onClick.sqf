/*
 * Author: Tasman Dynamics
 * MouseButtonDown handler for the Map Picker's map control (RscDisplayAFCM_SIM_MapPicker). Left
 * click only (_button == 0, real convention - 0=left, 1=right, 2=middle). Converts the click's
 * screen-space coordinates to a real world position via the real `ctrlMapScreenToWorld` command
 * and stashes it in AFCM_SIM_UI_mapPickerPos (a pending pick, not committed until Confirm is
 * clicked - fnc_mapPicker_onConfirm.sqf). Updates the hint text with the real grid reference
 * (`mapGridPosition`, real command) so there's clear feedback on exactly what was picked before
 * committing to it.
 *
 * Also drops a real local marker (`createMarkerLocal`/`setMarkerPosLocal` - client-side only,
 * never synced, exactly right for a pure UI preview aid) at the picked position so it's visible
 * directly on the map, not just as text - moves the same marker on every subsequent click rather
 * than creating a new one each time. Cleaned up on dialog close regardless of how
 * (fnc_mapPicker_cleanup.sqf, onUnload).
 *
 * Real MouseButtonDown signature: _this = [_control, _button, _x, _y, _shift, _ctrl, _alt].
 *
 * Arguments (from the MouseButtonDown event, not called directly):
 * 0: Map control <CONTROL>
 * 1: Button <NUMBER>
 * 2: X <NUMBER>
 * 3: Y <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlMap", "_button", "_x", "_y"];

if (_button != 0) exitWith {};

private _worldPos = _ctrlMap ctrlMapScreenToWorld [_x, _y];
missionNamespace setVariable ["AFCM_SIM_UI_mapPickerPos", _worldPos];

private _markerName = missionNamespace getVariable ["AFCM_SIM_UI_mapPickerMarker", ""];
if (_markerName isEqualTo "") then {
    _markerName = createMarkerLocal ["AFCM_SIM_mapPickerMarker", _worldPos];
    _markerName setMarkerTypeLocal "hd_dot";
    _markerName setMarkerColorLocal "ColorRed";
    _markerName setMarkerTextLocal "MCI Location";
    missionNamespace setVariable ["AFCM_SIM_UI_mapPickerMarker", _markerName];
} else {
    _markerName setMarkerPosLocal _worldPos;
};

private _display = ctrlParent _ctrlMap;
(_display displayCtrl 1) ctrlSetText format ["Selected: %1 — click Confirm, or click elsewhere to change.", mapGridPosition _worldPos];
