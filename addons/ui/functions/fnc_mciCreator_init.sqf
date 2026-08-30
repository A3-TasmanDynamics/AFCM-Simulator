/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_MciCreator. Initializes AFCM_SIM_UI_mciPatientSpecs
 * (missionNamespace Array of spec strings, one per patient - "random" or a real Preset id, the
 * actual working state of the incident being built) if this is the first time the tool's been
 * opened this session, defaulting to 3 patients ("a HE shell hit a section, 3 are down"). Reopening
 * the dialog later keeps whatever was last configured, rather than resetting every time.
 *
 * Populates the Patient Count / Casualty Type combos and both listboxes, then wires every control's
 * event handler exactly once - the populate* helper functions are separate specifically so
 * subsequent refreshes (after Assign/Randomize All/patient count change/loading an MCI preset)
 * never re-register a handler a second time.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryEditor_init.sqf.
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

if (isNil "AFCM_SIM_UI_mciPatientSpecs") then {
    AFCM_SIM_UI_mciPatientSpecs = ["random", "random", "random"];
};

[{
    disableSerialization;
    params ["_display"];

    private _counts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    private _countLB = _display displayCtrl 10;
    lbClear _countLB;
    { _countLB lbAdd (str _x); _countLB lbSetValue [_forEachIndex, _x]; } forEach _counts;
    private _countIdx = _counts find (count AFCM_SIM_UI_mciPatientSpecs);
    _countLB lbSetCurSel ([_countIdx, 2] select (_countIdx == -1));

    private _ctLB = _display displayCtrl 11;
    lbClear _ctLB;
    {
        _x params ["_label", "_value"];
        _ctLB lbAdd _label;
        _ctLB lbSetValue [_forEachIndex, _value];
    } forEach [["Civilian", 0], ["Military (BLUFOR)", 1], ["Military (OPFOR)", 2], ["Military (Independent)", 3]];
    _ctLB lbSetCurSel (missionNamespace getVariable ["AFCM_SIM_UI_mciCasualtyType", 0]);

    [_display] call afcm_sim_ui_fnc_mciCreator_populatePatientList;
    [_display] call afcm_sim_ui_fnc_mciCreator_populatePresetList;
    [_display] call afcm_sim_ui_fnc_mciCreator_refreshLocationStatus;

    _countLB ctrlAddEventHandler ["LBSelChanged", afcm_sim_ui_fnc_mciCreator_onPatientCountChanged];
    (_display displayCtrl 14) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciCreator_onAssign];
    (_display displayCtrl 15) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciCreator_onRandomizeAll];
    (_display displayCtrl 17) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciCreator_onChooseLocation];
    (_display displayCtrl 18) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciCreator_onSavePreset];
    (_display displayCtrl 19) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciCreator_onLoadPreset];
    (_display displayCtrl 20) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciCreator_onSpawn];
}, [_display]] call CBA_fnc_execNextFrame;
