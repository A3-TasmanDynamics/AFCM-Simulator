/*
 * Author: Tasman Dynamics
 * LBSelChanged handler for the MCI Creator's Patient Count combo (RscCombo is a listbox
 * internally, same real "LBSelChanged" event as a plain RscListBox). Grows or shrinks
 * AFCM_SIM_UI_mciPatientSpecs to match - new slots default to "random"; shrinking just truncates
 * (real `resize` command), discarding whatever was assigned to the removed trailing slots.
 *
 * Reads the target count back via the real `lbValue` command (the value fnc_mciCreator_init.sqf/
 * fnc_mciPresetLibrary_onLoad.sqf set on each row with `lbSetValue`) rather than a hardcoded
 * 1-10 array - those two now sometimes append an 11th row for the real current count when it's
 * outside 1-10 (a loaded/imported MCI preset with more than 10 patients), so re-deriving the value
 * from a fixed local array here would silently misread that row's index as the wrong count.
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
private _newCount = _ctrlCount lbValue _index;

if (_newCount > count AFCM_SIM_UI_mciPatientSpecs) then {
    for "_i" from (count AFCM_SIM_UI_mciPatientSpecs) + 1 to _newCount do {
        AFCM_SIM_UI_mciPatientSpecs pushBack "random";
    };
} else {
    AFCM_SIM_UI_mciPatientSpecs resize _newCount;
};

[_display] call afcm_sim_ui_fnc_mciCreator_populatePatientList;
