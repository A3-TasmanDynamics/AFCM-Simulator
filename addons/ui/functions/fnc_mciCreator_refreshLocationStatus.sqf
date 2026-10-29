/*
 * Author: Tasman Dynamics
 * Updates the MCI Creator's location status text and enables/disables Spawn MCI based on whether
 * AFCM_SIM_UI_mciLocation has actually been set yet (fnc_mapPicker_onConfirm.sqf) - spawning at an
 * unset/objNull position would silently misplace the whole incident, so Spawn stays disabled until
 * a real location exists.
 *
 * Also re-syncs the Radius field (idc 25) from AFCM_SIM_UI_mciRadius - this runs right after the
 * Map Picker's own Confirm (fnc_mapPicker_onConfirm.sqf writes that var there), so editing the
 * radius from the map reflects back onto this dialog's own field too, keeping both in sync.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_MciCreator <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display"];

disableSerialization;

private _pos = missionNamespace getVariable ["AFCM_SIM_UI_mciLocation", []];
private _hasPos = _pos isNotEqualTo [];

private _text = if (_hasPos) then {
    format ["Location: set — %1", mapGridPosition _pos]
} else {
    "Location: not set yet"
};

(_display displayCtrl 16) ctrlSetText _text;
(_display displayCtrl 20) ctrlEnable _hasPos;
(_display displayCtrl 25) ctrlSetText str (missionNamespace getVariable ["AFCM_SIM_UI_mciRadius", 10]);
