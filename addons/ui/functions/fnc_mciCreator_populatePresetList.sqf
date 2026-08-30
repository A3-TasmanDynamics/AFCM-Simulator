/*
 * Author: Tasman Dynamics
 * Refills the MCI Creator's Preset listbox - "Random" first (real command `lbSetData` tags it with
 * the same "random" sentinel fnc_resolveMciPatientSpec.sqf recognizes), then every built-in Preset,
 * then every user-saved one, each row tagged with its real Preset id. Split out from
 * fnc_mciCreator_init.sqf so it's callable again without re-registering handlers, though in
 * practice the preset library rarely changes while this dialog is open.
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

private _list = _display displayCtrl 13;
lbClear _list;

private _randomIdx = _list lbAdd "Random";
_list lbSetData [_randomIdx, "random"];

{
    private _idx = _list lbAdd (_x select 1);
    _list lbSetData [_idx, _x select 0];
} forEach ((call afcm_sim_scenario_fnc_getBuiltinPresets) + (call afcm_sim_scenario_fnc_getUserPresets));
