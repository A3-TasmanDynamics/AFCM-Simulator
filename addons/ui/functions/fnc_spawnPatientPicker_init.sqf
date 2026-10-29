/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_SpawnPatientPicker. Populates the Casualty Type combo
 * (same 4 real values every other Casualty Type picker in this addon uses - MCI Creator's own,
 * fnc_mciCreator_init.sqf) and prefills the selection from whatever was last actually spawned with
 * this picker, on request ("save across patient creation so I can place the module again and it
 * already has the selection that I previously used") - AFCM_SIM_lastSpawnPatientCasualtyType, a
 * profileNamespace value (survives between missions, same persistence class afcm_sim_
 * rememberLastInjuries' own remembered set uses), falling back to afcm_sim_defaultCasualtyType
 * (the existing Addon Option) the very first time it's ever opened.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryAuthor_init.sqf.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_SpawnPatientPicker <DISPLAY>
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

    private _ctLB = _display displayCtrl 10;
    lbClear _ctLB;
    {
        _x params ["_label", "_value"];
        _ctLB lbAdd _label;
        _ctLB lbSetValue [_forEachIndex, _value];
    } forEach [["Civilian", 0], ["Military (BLUFOR)", 1], ["Military (OPFOR)", 2], ["Military (Independent)", 3]];

    private _lastType = profileNamespace getVariable ["AFCM_SIM_lastSpawnPatientCasualtyType", afcm_sim_defaultCasualtyType];
    _ctLB lbSetCurSel _lastType;

    (_display displayCtrl 11) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_spawnPatientPicker_onSpawn];
}, [_display]] call CBA_fnc_execNextFrame;
