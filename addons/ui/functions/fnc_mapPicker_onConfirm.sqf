/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Map Picker's Confirm button. Commits the pending click
 * (AFCM_SIM_UI_mapPickerPos, set by fnc_mapPicker_onClick.sqf) as the real MCI location
 * (AFCM_SIM_UI_mciLocation), closes this dialog, then refreshes the MCI Creator's location status
 * text/Spawn-button-enabled state if it's still open underneath.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Confirm button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlConfirm"];

private _pos = missionNamespace getVariable ["AFCM_SIM_UI_mapPickerPos", []];

if (_pos isEqualTo []) exitWith {
    diag_log text "[AFCM-Simulator][UI] Map Picker Confirm clicked with no position chosen - ignored.";
};

AFCM_SIM_UI_mciLocation = _pos;
missionNamespace setVariable ["AFCM_SIM_UI_mapPickerPos", nil];

closeDialog 0;

// 25605 = IDD_AFCM_SIM_MCICREATOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
[{
    private _mciDisplay = findDisplay 25605;
    if !(isNull _mciDisplay) then {
        [_mciDisplay] call afcm_sim_ui_fnc_mciCreator_refreshLocationStatus;
    };
}, []] call CBA_fnc_execNextFrame;
