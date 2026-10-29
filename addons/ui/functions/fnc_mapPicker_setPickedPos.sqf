/*
 * Author: Tasman Dynamics
 * Shared "commit a picked world position to the Map Picker's preview" logic - creates/moves the
 * real local point marker (`createMarkerLocal`/`setMarkerPosLocal`, same as before) and, in MCI
 * context (Radius controls shown, fnc_mapPicker_init.sqf), the radius ELLIPSE preview marker
 * (`setMarkerShapeLocal "ELLIPSE"`/`setMarkerSizeLocal`/`setMarkerBrushLocal "Border"` - outline
 * only, doesn't obscure the map underneath), then updates the hint text. Extracted out of
 * fnc_mapPicker_onClick.sqf so fnc_mapPicker_init.sqf can reuse the exact same logic to pre-seed the
 * preview from an already-set AFCM_SIM_UI_mciLocation (the Zeus-placed MCI Spawner flow,
 * fnc_module_mciSpawner.sqf) without duplicating marker-creation code.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_MapPicker <DISPLAY>
 * 1: World position <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display", "_worldPos"];

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

if (ctrlShown (_display displayCtrl 14)) then {
    private _radius = 0 max (parseNumber (ctrlText (_display displayCtrl 14)));
    private _ellipseName = missionNamespace getVariable ["AFCM_SIM_UI_mapPickerEllipse", ""];
    if (_ellipseName isEqualTo "") then {
        _ellipseName = createMarkerLocal ["AFCM_SIM_mapPickerEllipse", _worldPos];
        _ellipseName setMarkerShapeLocal "ELLIPSE";
        _ellipseName setMarkerBrushLocal "Border";
        _ellipseName setMarkerColorLocal "ColorRed";
        _ellipseName setMarkerSizeLocal [_radius, _radius];
        missionNamespace setVariable ["AFCM_SIM_UI_mapPickerEllipse", _ellipseName];
    } else {
        _ellipseName setMarkerPosLocal _worldPos;
        _ellipseName setMarkerSizeLocal [_radius, _radius];
    };
};

(_display displayCtrl 1) ctrlSetText format ["Selected: %1 — click Confirm, or click elsewhere to change.", mapGridPosition _worldPos];
