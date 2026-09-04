/*
 * Author: Tasman Dynamics
 * Loads a preset's injuries/katExtras straight into the Injury Author dialog's staged arrays and
 * reopens it - called by fnc_presetLibrary_onApply.sqf's new "staging" branch
 * (AFCM_SIM_UI_targetStaging), the counterpart to fnc_injuryAuthor_onLoadPreset.sqf closing this
 * dialog and opening the Preset Library in the first place.
 *
 * Reopens via afcm_sim_ui_fnc_injuryAuthor_open with _preserveStaged=true so the normal open-time
 * reset/remember-last-used logic doesn't immediately clobber what was just loaded here.
 * AFCM_SIM_UI_targetUnit is already whatever it was before Load Preset was clicked (edit mode keeps
 * its live unit; author-new-patient mode stays objNull) - fnc_injuryAuthor_onLoadPreset.sqf never
 * touched it.
 *
 * Arguments:
 * 0: Injuries <ARRAY of [limb, woundType, severity, bleeding, bleedRate?]>
 * 1: katExtras <ARRAY> (default [])
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_injuries", ["_katExtras", []]];

missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", _injuries];
missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", if (_katExtras isEqualTo []) then { [[0, 0, 0, 0, 0, 0], 0, 0, 0] } else { _katExtras }];

[{
    private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
    [_targetUnit, true] call afcm_sim_ui_fnc_injuryAuthor_open;
}, []] call CBA_fnc_execNextFrame;
