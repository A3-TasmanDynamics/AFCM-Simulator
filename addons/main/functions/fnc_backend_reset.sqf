/*
 * Author: Tasman Dynamics
 * Dispatches a full medical reset to whichever backend the server selected as active
 * (DESIGN.md §2.5), mirroring fnc_backend_applyInjury.sqf's dispatch pattern. Lets an instructor
 * wipe everything that's been done to a patient so far (wounds, bandages, drugs) and start the
 * treatment exercise over, without needing to delete and respawn the unit.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 *
 * Return Value:
 * Bool - true if the active backend handled it, false if no backend is active/registered here or
 * the active backend doesn't implement reset
 *
 * Public: No
*/

params ["_unit"];

private _backendId = missionNamespace getVariable ["AFCM_SIM_activeBackend", ""];

if (_backendId isEqualTo "") exitWith {
    diag_log text "[AFCM-Simulator] reset called with no active backend - ignored.";
    false
};

private _registry = missionNamespace getVariable ["AFCM_SIM_backendRegistry", createHashMap];
private _entry = _registry get _backendId;

if (isNil "_entry") exitWith {
    diag_log text format ["[AFCM-Simulator] reset: server-selected backend '%1' is not registered on this machine (mod mismatch?) - ignored.", _backendId];
    false
};

private _interface = _entry select 1;
private _fnc = _interface get "reset";

if (isNil "_fnc") exitWith {
    diag_log text format ["[AFCM-Simulator] reset: backend '%1' has no reset implementation - ignored.", _backendId];
    false
};

[_unit] call _fnc;
true
