/*
 * Author: Tasman Dynamics
 * Refills the MCI Creator's Patient listbox from AFCM_SIM_UI_mciPatientSpecs (the working state),
 * one row per patient reading "Patient N — <preset name / Random>". Split out from
 * fnc_mciCreator_init.sqf so it can be called again after any change (Assign, Randomize All,
 * patient count change, loading an MCI preset) without re-registering event handlers.
 *
 * Preserves the current selection index across a refresh where possible, so e.g. clicking Assign
 * repeatedly on the same patient while trying different presets doesn't lose your place.
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

disableSerialization;

private _list = _display displayCtrl 12;
private _curSel = lbCurSel _list;
lbClear _list;

{
    private _spec = _x;
    private _label = if (_spec isEqualTo "random") then { "Random" } else {
        private _preset = [_spec] call afcm_sim_scenario_fnc_findPreset;
        if (_preset isEqualTo []) then { format ["<missing preset: %1>", _spec] } else { _preset select 1 };
    };
    _list lbAdd format ["Patient %1 — %2", _forEachIndex + 1, _label];
} forEach AFCM_SIM_UI_mciPatientSpecs;

if (_curSel != -1 && {_curSel < count AFCM_SIM_UI_mciPatientSpecs}) then {
    _list lbSetCurSel _curSel;
};
