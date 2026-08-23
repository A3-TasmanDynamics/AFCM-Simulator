/*
 * Author: Tasman Dynamics
 * Dispatches a live medical-state query to whichever backend the server selected as active
 * (DESIGN.md §2.5), mirroring fnc_backend_applyInjury.sqf's dispatch pattern. Unlike applyInjury,
 * this is read-only and safe to call from any machine (not server-only) - each backend's own
 * getState implementation is responsible for only using getters that don't require `local _unit`
 * (afcm_sim_ace's uses ace_medical_fnc_isInjured/getOpenWounds, not the local-only getBloodLoss).
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> (default "") - if given, backends may include limb-specific wound detail
 *
 * Return Value:
 * State <HASHMAP> - backend-defined fields; empty HashMap if no backend is active, not registered
 * on this machine, or the active backend doesn't implement getState
 *
 * Public: No
*/

params ["_unit", ["_limb", ""]];

private _backendId = missionNamespace getVariable ["AFCM_SIM_activeBackend", ""];

if (_backendId isEqualTo "") exitWith { createHashMap };

private _registry = missionNamespace getVariable ["AFCM_SIM_backendRegistry", createHashMap];
private _entry = _registry get _backendId;

if (isNil "_entry") exitWith { createHashMap };

private _interface = _entry select 1;
private _fnc = _interface get "getState";

if (isNil "_fnc") exitWith { createHashMap };

[_unit, _limb] call _fnc
