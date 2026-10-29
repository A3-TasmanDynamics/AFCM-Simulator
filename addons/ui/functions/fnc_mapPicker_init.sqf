/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_MapPicker - wires the map's real MouseButtonDown event
 * (real control event, `_this = [_control, _button, _x, _y, _shift, _ctrl, _alt]`) and the Confirm
 * button. Cancel is a plain `action = "closeDialog 0;"` in config.cpp.
 *
 * MCI context only (MCI Creator, IDD 25605, open underneath - same findDisplay check
 * fnc_mapPicker_onConfirm.sqf already uses to decide which caller to write back to): shows the
 * Radius controls (hidden for the Injury Author's single-point ChooseLocation, where a radius means
 * nothing), pre-fills Radius from AFCM_SIM_UI_mciRadius, and - on request ("marker is already
 * placed" for the Zeus-placed MCI Spawner flow, fnc_module_mciSpawner.sqf pre-sets
 * AFCM_SIM_UI_mciLocation before opening) - pre-seeds the point+radius preview from
 * AFCM_SIM_UI_mciLocation if one is already set, rather than starting blank until the first click.
 * A small CBA_fnc_addPerFrameHandler keeps the radius ellipse synced to the Radius field live
 * (RscEdit has no reliable "value changed" event) and to the point marker's position after every
 * click - stopped in fnc_mapPicker_cleanup.sqf.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryAuthor_init.sqf.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_MapPicker <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display"];

[{
    disableSerialization;
    params ["_display"];
    (_display displayCtrl 10) ctrlAddEventHandler ["MouseButtonDown", afcm_sim_ui_fnc_mapPicker_onClick];
    (_display displayCtrl 11) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mapPicker_onConfirm];

    // 25605 = IDD_AFCM_SIM_MCICREATOR (addons/ui/config.cpp) - hardcoded since #defines aren't
    // available in SQF; keep in sync if that IDD ever changes.
    private _isMci = !(isNull (findDisplay 25605));
    { (_display displayCtrl _x) ctrlShow _isMci; } forEach [13, 14];

    if (_isMci) then {
        (_display displayCtrl 14) ctrlSetText str (missionNamespace getVariable ["AFCM_SIM_UI_mciRadius", 10]);

        private _existingPos = missionNamespace getVariable ["AFCM_SIM_UI_mciLocation", []];
        if (_existingPos isNotEqualTo []) then {
            [_display, _existingPos] call afcm_sim_ui_fnc_mapPicker_setPickedPos;
        };

        private _pfhHandle = [{
            params ["_args", "_handle"];
            _args params ["_display"];
            if (isNull _display) exitWith { [_handle] call CBA_fnc_removePerFrameHandler; };
            private _ellipseName = missionNamespace getVariable ["AFCM_SIM_UI_mapPickerEllipse", ""];
            if (_ellipseName == "") exitWith {};
            private _radius = 0 max (parseNumber (ctrlText (_display displayCtrl 14)));
            _ellipseName setMarkerSizeLocal [_radius, _radius];
        }, 0.1, [_display]] call CBA_fnc_addPerFrameHandler;
        missionNamespace setVariable ["AFCM_SIM_UI_mapPickerRadiusPfh", _pfhHandle];
    };
}, [_display]] call CBA_fnc_execNextFrame;
