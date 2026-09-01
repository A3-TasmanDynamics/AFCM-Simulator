/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Preset Library's Load button. Replaces the MCI Creator's whole
 * working patient list (AFCM_SIM_UI_mciPatientSpecs) with the selected MCI preset's patientSpecs -
 * a `+` (real unary copy operator) so mutating it afterward (Assign, Randomize All, patient count
 * changes) never corrupts the stored preset itself, especially important for user-saved ones where
 * fnc_getUserMciPresets.sqf returns the actual profileNamespace-backed array, not a copy.
 *
 * Doesn't apply anything to a unit - MCI presets are a template for the Creator to build from, not
 * something spawned straight from this dialog.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Load button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlLoad"];

private _display = ctrlParent _ctrlLoad;
private _index = lbCurSel (_display displayCtrl 10);
if (_index == -1) exitWith {};

private _id = (_display displayCtrl 10) lbData _index;
private _mciPreset = [_id] call afcm_sim_scenario_fnc_findMciPreset;
if (_mciPreset isEqualTo []) exitWith {};

AFCM_SIM_UI_mciPatientSpecs = +(_mciPreset select 4);

closeDialog 0;

// 25605 = IDD_AFCM_SIM_MCICREATOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
[{
    private _mciDisplay = findDisplay 25605;
    if !(isNull _mciDisplay) then {
        [_mciDisplay] call afcm_sim_ui_fnc_mciCreator_populatePatientList;

        // Real, confirmed bug fixed here: a loaded MCI preset with more than 10 patients (no hard
        // cap on preset size) used to leave the Patient Count dropdown showing whatever it last
        // displayed instead of the real count - same fix as fnc_mciCreator_init.sqf's own combo
        // population, rebuild the option list to include the real count rather than just skipping
        // the selection update when it's outside 1-10.
        private _countLB = _mciDisplay displayCtrl 10;
        private _counts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        private _realCount = count AFCM_SIM_UI_mciPatientSpecs;
        if !(_realCount in _counts) then { _counts pushBack _realCount; };
        lbClear _countLB;
        { _countLB lbAdd (str _x); _countLB lbSetValue [_forEachIndex, _x]; } forEach _counts;
        _countLB lbSetCurSel (_counts find _realCount);
    };
}, []] call CBA_fnc_execNextFrame;
