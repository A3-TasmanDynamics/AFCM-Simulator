/*
 * Author: Tasman Dynamics
 * Dispatches to whichever backend the server selected as active (DESIGN.md §2.5) for its real
 * woundType id/label list, mirroring fnc_backend_reset.sqf's dispatch pattern. No unit argument -
 * unlike every other backend op, this just asks "what wound types does the active backend support",
 * not "do X to this unit".
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Array of [Id <STRING>, Label <STRING>] pairs, or [] if no backend is active/registered here or
 * the active backend doesn't implement getWoundTypes
 *
 * Public: No
*/

private _backendId = missionNamespace getVariable ["AFCM_SIM_activeBackend", ""];

if (_backendId isEqualTo "") exitWith {
    diag_log text "[AFCM-Simulator] getWoundTypes called with no active backend - ignored.";
    []
};

private _registry = missionNamespace getVariable ["AFCM_SIM_backendRegistry", createHashMap];
private _entry = _registry get _backendId;

if (isNil "_entry") exitWith {
    diag_log text format ["[AFCM-Simulator] getWoundTypes: server-selected backend '%1' is not registered on this machine (mod mismatch?) - ignored.", _backendId];
    []
};

private _interface = _entry select 1;
private _fnc = _interface get "getWoundTypes";

if (isNil "_fnc") exitWith {
    diag_log text format ["[AFCM-Simulator] getWoundTypes: backend '%1' has no getWoundTypes implementation - ignored.", _backendId];
    []
};

call _fnc
