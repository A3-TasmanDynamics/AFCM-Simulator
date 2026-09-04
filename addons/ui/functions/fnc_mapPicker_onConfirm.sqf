/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Map Picker's Confirm button. Commits the pending click
 * (AFCM_SIM_UI_mapPickerPos, set by fnc_mapPicker_onClick.sqf), closes this dialog, then writes it
 * into whichever real caller is actually open underneath and refreshes that caller's own location
 * status/Apply-or-Spawn-enabled state:
 *  - MCI Creator (IDD 25605, fnc_mciCreator_onChooseLocation.sqf) -> AFCM_SIM_UI_mciLocation +
 *    fnc_mciCreator_refreshLocationStatus.sqf.
 *  - Injury Author, author-new-patient mode (IDD 25611, fnc_injuryAuthor_onChooseLocation.sqf) ->
 *    AFCM_SIM_UI_authorSpawnPos + fnc_injuryAuthor_refreshLocationStatus.sqf.
 * Both checked via findDisplay rather than tracking "who opened me" explicitly - only one of the
 * two is ever realistically open underneath the Map Picker at once, so checking both and acting on
 * whichever is actually there is safe and avoids adding a third piece of state just for this.
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

missionNamespace setVariable ["AFCM_SIM_UI_mapPickerPos", nil];

closeDialog 0;

// 25605 = IDD_AFCM_SIM_MCICREATOR, 25611 = IDD_AFCM_SIM_INJURYAUTHOR (addons/ui/config.cpp) -
// hardcoded since #defines aren't available in SQF; keep in sync if either IDD ever changes.
if (isNull (findDisplay 25605)) then {
    if !(isNull (findDisplay 25611)) then {
        missionNamespace setVariable ["AFCM_SIM_UI_authorSpawnPos", _pos];
        [{
            private _iaDisplay = findDisplay 25611;
            if !(isNull _iaDisplay) then {
                call afcm_sim_ui_fnc_injuryAuthor_refreshLocationStatus;
            };
        }, []] call CBA_fnc_execNextFrame;
    };
} else {
    AFCM_SIM_UI_mciLocation = _pos;
    [{
        private _mciDisplay = findDisplay 25605;
        if !(isNull _mciDisplay) then {
            [_mciDisplay] call afcm_sim_ui_fnc_mciCreator_refreshLocationStatus;
        };
    }, []] call CBA_fnc_execNextFrame;
};
