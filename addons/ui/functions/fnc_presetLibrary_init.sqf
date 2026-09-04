/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_PresetLibrary. Populates the list
 * (fnc_presetLibrary_populateList.sqf) and wires every control's event handler exactly once -
 * fnc_presetLibrary_onDelete.sqf/fnc_presetLibrary_onImport.sqf call populateList directly to
 * refresh after a change, not this function, specifically so handlers never get registered twice.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryAuthor_init.sqf - ensures
 * controls exist before being touched.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_PresetLibrary <DISPLAY>
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

    [_display] call afcm_sim_ui_fnc_presetLibrary_populateList;

    (_display displayCtrl 10) ctrlAddEventHandler ["LBSelChanged", afcm_sim_ui_fnc_presetLibrary_onSelect];
    (_display displayCtrl 11) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_presetLibrary_onApply];
    (_display displayCtrl 12) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_presetLibrary_onDelete];
    (_display displayCtrl 13) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_presetLibrary_onExport];
    (_display displayCtrl 15) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_presetLibrary_onImport];
}, [_display]] call CBA_fnc_execNextFrame;
