/*
 * Author: Tasman Dynamics
 * Dispatches a blood volume/SpO2 write to whichever backend the server selected as active
 * (DESIGN.md §2.5), mirroring fnc_backend_setUnconscious.sqf's dispatch pattern.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Blood volume <NUMBER> - litres
 * 2: SpO2 <NUMBER> - percent
 *
 * Return Value:
 * Bool - true if the active backend handled it, false if no backend is active/registered here or
 * the active backend doesn't implement setVitals
 *
 * Public: No
*/

params ["_unit", "_bloodVolume", "_spo2"];

private _backendId = missionNamespace getVariable ["AFCM_SIM_activeBackend", ""];

if (_backendId isEqualTo "") exitWith {
    diag_log text "[AFCM-Simulator] setVitals called with no active backend - ignored.";
    false
};

private _registry = missionNamespace getVariable ["AFCM_SIM_backendRegistry", createHashMap];
private _entry = _registry get _backendId;

if (isNil "_entry") exitWith {
    diag_log text format ["[AFCM-Simulator] setVitals: server-selected backend '%1' is not registered on this machine (mod mismatch?) - ignored.", _backendId];
    false
};

private _interface = _entry select 1;
private _fnc = _interface get "setVitals";

if (isNil "_fnc") exitWith {
    diag_log text format ["[AFCM-Simulator] setVitals: backend '%1' has no setVitals implementation - ignored.", _backendId];
    false
};

[_unit, _bloodVolume, _spo2] call _fnc;
true
