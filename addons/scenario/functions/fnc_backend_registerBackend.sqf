/*
 * Author: Tasman Dynamics
 * Registers a medical backend as available on this machine. Called by a backend addon's own
 * preInit (afcm_sim_backend_ace, afcm_sim_backend_afcm) — never call this from outside a backend
 * addon. Runs identically on server and every client that has the corresponding backend PBO
 * loaded; registration itself is purely local, only *selection* (fnc_backend_selectBackend.sqf)
 * needs to be server-authoritative and broadcast. See DESIGN.md §2.5/§6.
 *
 * Arguments:
 * 0: Backend id <STRING> - e.g. "afcm", "ace"
 * 1: Priority <NUMBER> - higher wins; AFCM should register higher than ACE (native path preferred)
 * 2: Interface <HASHMAP> - maps interface function name (e.g. "applyInjury") to this backend's
 *    own compiled implementation
 *
 * Return Value:
 * None
 *
 * Example:
 * ["ace", 10, _interface] call afcm_sim_fnc_backend_registerBackend
 *
 * Public: No
*/

params ["_backendId", "_priority", "_interface"];

private _registry = missionNamespace getVariable ["AFCM_SIM_backendRegistry", createHashMap];
_registry set [_backendId, [_priority, _interface]];
missionNamespace setVariable ["AFCM_SIM_backendRegistry", _registry];

diag_log text format ["[AFCM-Simulator] Backend registered locally: %1 (priority %2)", _backendId, _priority];
