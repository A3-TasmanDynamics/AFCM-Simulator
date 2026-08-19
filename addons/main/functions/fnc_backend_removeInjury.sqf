/*
 * Author: Tasman Dynamics
 * Dispatches an injury removal to whichever backend the server selected as active
 * (DESIGN.md §2.5/§4.2). afcm_sim_scenario and afcm_sim_spawner call this - never a backend
 * addon's function directly, and never AFCM/ACE3 directly.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Injury <HASHMAP> - see DESIGN.md §4.2 Injury object schema
 *
 * Return Value:
 * Bool - true if the active backend handled it, false if no backend is active/registered here
 *
 * Public: No
*/

params ["_unit", "_injury"];

private _backendId = missionNamespace getVariable ["AFCM_SIM_activeBackend", ""];

if (_backendId isEqualTo "") exitWith {
    diag_log text "[AFCM-Simulator] removeInjury called with no active backend - ignored.";
    false
};

private _registry = missionNamespace getVariable ["AFCM_SIM_backendRegistry", createHashMap];
private _entry = _registry get _backendId;

if (isNil "_entry") exitWith {
    diag_log text format ["[AFCM-Simulator] removeInjury: server-selected backend '%1' is not registered on this machine (mod mismatch?) - ignored.", _backendId];
    false
};

private _interface = _entry select 1;
private _fnc = _interface get "removeInjury";

if (isNil "_fnc") exitWith {
    diag_log text format ["[AFCM-Simulator] removeInjury: backend '%1' has no removeInjury implementation - ignored.", _backendId];
    false
};

[_unit, _injury] call _fnc;
true
