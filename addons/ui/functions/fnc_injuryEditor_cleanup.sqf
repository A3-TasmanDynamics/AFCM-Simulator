/*
 * Author: Tasman Dynamics
 * onUnload handler for RscDisplayAFCM_SIM_InjuryEditor. Removes the per-frame handler
 * fnc_injuryEditor_init.sqf started for the live status readout - without this it would keep
 * polling afcm_sim_fnc_backend_getState forever after the dialog closes.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_InjuryEditor <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

private _handle = missionNamespace getVariable ["AFCM_SIM_UI_statePFH", -1];

if (_handle != -1) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    missionNamespace setVariable ["AFCM_SIM_UI_statePFH", -1];
};
