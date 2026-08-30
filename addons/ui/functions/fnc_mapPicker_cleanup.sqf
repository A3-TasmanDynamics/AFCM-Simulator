/*
 * Author: Tasman Dynamics
 * onUnload handler for RscDisplayAFCM_SIM_MapPicker. Deletes the local preview marker
 * (`deleteMarkerLocal`, real command) fnc_mapPicker_onClick.sqf drops at the picked position, if
 * one was ever created - runs regardless of how the dialog closed (Confirm, Cancel, or Escape),
 * unlike a handler wired to just one specific button.
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
