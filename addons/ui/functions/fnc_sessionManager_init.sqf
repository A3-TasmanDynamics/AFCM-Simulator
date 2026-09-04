/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_SessionManager. Populates the list
 * (fnc_sessionManager_populateList.sqf) and wires every control's event handler exactly once -
 * fnc_sessionManager_onDeleteSession.sqf/fnc_sessionManager_onClearAll.sqf call populateList
 * directly to refresh after a change, not this function, so handlers never get registered twice
 * (ctrlAddEventHandler adds, it doesn't replace).
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryAuthor_init.sqf.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_SessionManager <DISPLAY>
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

    [_display] call afcm_sim_ui_fnc_sessionManager_populateList;

    (_display displayCtrl 10) ctrlAddEventHandler ["LBSelChanged", afcm_sim_ui_fnc_sessionManager_onSelect];
    (_display displayCtrl 11) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_sessionManager_onDeleteSession];
    (_display displayCtrl 12) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_sessionManager_onClearAll];
}, [_display]] call CBA_fnc_execNextFrame;
