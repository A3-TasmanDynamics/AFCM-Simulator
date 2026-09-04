/*
 * Author: Tasman Dynamics
 * Updates the Injury Author dialog's LocationStatus text and enables/disables Apply based on
 * whether AFCM_SIM_UI_authorSpawnPos has actually been set yet (fnc_mapPicker_onConfirm.sqf) -
 * same "disabled until location chosen" pattern as fnc_mciCreator_refreshLocationStatus.sqf, since
 * spawning at an unset position would silently misplace the patient. Author-new-patient mode only -
 * callers only ever invoke this when AFCM_SIM_UI_authorNewPatient is true (edit mode has no spawn
 * location concept at all, and forcibly touching Apply's enabled state there would be wrong).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

disableSerialization;

// 25611 = IDD_AFCM_SIM_INJURYAUTHOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
private _display = findDisplay 25611;
if (isNull _display) exitWith {};

private _pos = missionNamespace getVariable ["AFCM_SIM_UI_authorSpawnPos", []];
private _hasPos = _pos isNotEqualTo [];

private _text = if (_hasPos) then {
    format ["Location: set — %1", mapGridPosition _pos]
} else {
    "Location: not set yet"
};

(_display displayCtrl 52) ctrlSetText _text;
(_display displayCtrl 40) ctrlEnable _hasPos;
