/*
 * Author: Tasman Dynamics
 * Dispatches an injury application to whichever backend the server selected as active
 * (DESIGN.md §2.5/§4.2). afcm_sim_scenario and afcm_sim_spawner call this - never a backend
 * addon's function directly, and never AFCM/ACE3 directly. Both real callers
 * (afcm_sim_scenario_fnc_serverApplyInjury, afcm_sim_spawner_fnc_spawnPatient) only ever run this
 * on the server, so the per-limb bookkeeping below (AFCM_SIM_appliedInjuries, publicVariable'd) is
 * safe to write unconditionally rather than needing its own isServer guard.
 *
 * That bookkeeping - one tracked [limb, woundType, severity, bleeding] tuple per limb, a fresh
 * apply on the same limb overwriting its own entry rather than appending - is what
 * fnc_exportPatientState.sqf reads back to let a controller export a hand-authored patient's
 * current injuries for reuse elsewhere (an Eden AFCM Patient module's Injury Preset Import
 * attribute, or the Preset Library) - there's no reliable way to reverse-engineer this addon's
 * simplified woundType strings back out of live ACE/KAT wound state, so it's tracked here at the
 * point of application instead. Deliberately a plain Array of primitives, not a HashMap of Injury
 * HashMaps - same "Array round-trips reliably, HashMap doesn't cross a network boundary the same
 * way" reasoning fnc_exportPreset.sqf documents, and this variable IS publicVariable'd (`true`
 * below) so every client can read it back locally when exporting, not just the server.
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
    diag_log text "[AFCM-Simulator] applyInjury called with no active backend - ignored.";
    false
};

private _registry = missionNamespace getVariable ["AFCM_SIM_backendRegistry", createHashMap];
private _entry = _registry get _backendId;

if (isNil "_entry") exitWith {
    diag_log text format ["[AFCM-Simulator] applyInjury: server-selected backend '%1' is not registered on this machine (mod mismatch?) - ignored.", _backendId];
    false
};

private _interface = _entry select 1;
private _fnc = _interface get "applyInjury";

if (isNil "_fnc") exitWith {
    diag_log text format ["[AFCM-Simulator] applyInjury: backend '%1' has no applyInjury implementation - ignored.", _backendId];
    false
};

[_unit, _injury] call _fnc;

private _limb = _injury getOrDefault ["limb", ""];
private _history = _unit getVariable ["AFCM_SIM_appliedInjuries", []];
_history = _history select { (_x select 0) != _limb };
_history pushBack [_limb, _injury getOrDefault ["woundType", ""], _injury getOrDefault ["severity", 0.5], _injury getOrDefault ["bleeding", false]];
_unit setVariable ["AFCM_SIM_appliedInjuries", _history, true];

true
