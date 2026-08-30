/*
 * Author: Tasman Dynamics
 * LBSelChanged handler for the MCI Creator's Patient Count combo (RscCombo is a listbox
 * internally, same real "LBSelChanged" event as a plain RscListBox). Grows or shrinks
 * AFCM_SIM_UI_mciPatientSpecs to match - new slots default to "random"; shrinking just truncates
 * (real `resize` command), discarding whatever was assigned to the removed trailing slots.
 *
 * Real LBSelChanged signature: _this = [_control, _selectedIndex].
 *
 * Arguments (from the LBSelChanged event, not called directly):
 * 0: Patient Count combo <CONTROL>
 * 1: Selected index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlCount", "_index"];

private _display = ctrlParent _ctrlCount;
private _counts = [1, 2, 3, 4, 5, 6, 8, 10];
private _newCount = _counts param [_index, 3];

if (_newCount > count AFCM_SIM_UI_mciPatientSpecs) then {
    for "_i" from (count AFCM_SIM_UI_mciPatientSpecs) + 1 to _newCount do {
        AFCM_SIM_UI_mciPatientSpecs pushBack "random";
    };
} else {
    AFCM_SIM_UI_mciPatientSpecs resize _newCount;
};

[_display] call afcm_sim_ui_fnc_mciCreator_populatePatientList;
