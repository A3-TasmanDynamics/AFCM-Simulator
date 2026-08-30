/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_MciPresetLibrary. Populates the list
 * (fnc_mciPresetLibrary_populateList.sqf) and wires every control's event handler exactly once -
 * fnc_mciPresetLibrary_onDelete.sqf/fnc_mciPresetLibrary_onImport.sqf call populateList directly
 * to refresh after a change, not this function, so handlers never get registered twice
 * (ctrlAddEventHandler adds, it doesn't replace).
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryEditor_init.sqf.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_MciPresetLibrary <DISPLAY>
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

    [_display] call afcm_sim_ui_fnc_mciPresetLibrary_populateList;

    (_display displayCtrl 10) ctrlAddEventHandler ["LBSelChanged", afcm_sim_ui_fnc_mciPresetLibrary_onSelect];
    (_display displayCtrl 11) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciPresetLibrary_onLoad];
    (_display displayCtrl 12) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciPresetLibrary_onDelete];
    (_display displayCtrl 13) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciPresetLibrary_onExport];
    (_display displayCtrl 15) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_mciPresetLibrary_onImport];
}, [_display]] call CBA_fnc_execNextFrame;
