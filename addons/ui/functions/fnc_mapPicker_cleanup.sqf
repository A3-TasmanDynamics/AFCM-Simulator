/*
 * Author: Tasman Dynamics
 * onUnload handler for RscDisplayAFCM_SIM_MapPicker. Deletes the local preview marker
 * (`deleteMarkerLocal`, real command) fnc_mapPicker_onClick.sqf drops at the picked position, if
 * one was ever created - runs regardless of how the dialog closed (Confirm, Cancel, or Escape),
 * unlike a handler wired to just one specific button.
 *
 * Also clears AFCM_SIM_UI_mapPickerPos here, for the same "runs no matter how the dialog closed"
 * reason - real, confirmed bug this fixes: Confirm already clears it itself
 * (fnc_mapPicker_onConfirm.sqf) after committing it to AFCM_SIM_UI_mciLocation, but Cancel/Escape
 * previously left it sitting there untouched. Reopening the Map Picker afterward and clicking
 * Confirm before ever clicking the map would silently re-commit the stale, previously-cancelled
 * position as the real MCI location - clearing it here means Confirm's own `_pos isEqualTo []`
 * guard actually catches that case instead.
 *
 * Also deletes the radius ELLIPSE preview marker and stops its sync PFH (fnc_mapPicker_init.sqf),
 * MCI context only - both no-ops (getVariable default "") when never created.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

private _markerName = missionNamespace getVariable ["AFCM_SIM_UI_mapPickerMarker", ""];

if (_markerName isNotEqualTo "") then {
    deleteMarkerLocal _markerName;
    missionNamespace setVariable ["AFCM_SIM_UI_mapPickerMarker", nil];
};

private _ellipseName = missionNamespace getVariable ["AFCM_SIM_UI_mapPickerEllipse", ""];

if (_ellipseName isNotEqualTo "") then {
    deleteMarkerLocal _ellipseName;
    missionNamespace setVariable ["AFCM_SIM_UI_mapPickerEllipse", nil];
};

private _pfhHandle = missionNamespace getVariable ["AFCM_SIM_UI_mapPickerRadiusPfh", -1];
if (_pfhHandle != -1) then {
    [_pfhHandle] call CBA_fnc_removePerFrameHandler;
    missionNamespace setVariable ["AFCM_SIM_UI_mapPickerRadiusPfh", nil];
};

missionNamespace setVariable ["AFCM_SIM_UI_mapPickerPos", nil];
