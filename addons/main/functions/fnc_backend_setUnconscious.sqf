/*
 * Author: Tasman Dynamics
 * Dispatches an unconsciousness re-lock to whichever backend the server selected as active
 * (DESIGN.md §2.5), mirroring fnc_backend_reset.sqf's dispatch pattern. Exists as its own backend
 * op (not just an inline `setUnconscious` call at the spawner/scenario layer) because the correct
 * way to knock a unit out is backend-specific: ACE/KAT track their own "ACE_isUnconscious"
 * variable via `ace_medical_fnc_setUnconscious`, entirely separate from the engine's own
 * `setUnconscious` command (REFERENCES.md — this distinction is the real root cause behind
 * patients "healing themselves").
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 *
 * Return Value:
 * Bool - true if the active backend handled it, false if no backend is active/registered here or
 * the active backend doesn't implement setUnconscious
 *
 * Public: No
*/

params ["_unit"];

private _backendId = missionNamespace getVariable ["AFCM_SIM_activeBackend", ""];

if (_backendId isEqualTo "") exitWith {
    diag_log text "[AFCM-Simulator] setUnconscious called with no active backend - ignored.";
    false
};

private _registry = missionNamespace getVariable ["AFCM_SIM_backendRegistry", createHashMap];
private _entry = _registry get _backendId;

if (isNil "_entry") exitWith {
    diag_log text format ["[AFCM-Simulator] setUnconscious: server-selected backend '%1' is not registered on this machine (mod mismatch?) - ignored.", _backendId];
    false
};

private _interface = _entry select 1;
private _fnc = _interface get "setUnconscious";

if (isNil "_fnc") exitWith {
    diag_log text format ["[AFCM-Simulator] setUnconscious: backend '%1' has no setUnconscious implementation - ignored.", _backendId];
    false
};

[_unit] call _fnc;
true
