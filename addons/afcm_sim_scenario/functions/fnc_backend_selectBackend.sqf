/*
 * Author: Tasman Dynamics
 * Server-side only: picks the highest-priority locally-registered backend and broadcasts the
 * winning id. Only the id (a String) is ever broadcast — never the interface itself, since
 * compiled Code cannot be sent over publicVariable, and every machine that has a given backend's
 * PBO loaded already has its own local copy of that backend's functions (DESIGN.md §2.5/§6).
 *
 * Runs once, triggered by "CBA_addons_postInit" (fnc_scenario_preInit.sqf), by which point every
 * addon's own preInit — where registration happens — has already run on this machine.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Selected backend id <STRING>, or "" if no backend is registered
 *
 * Public: No
*/

if !(isServer) exitWith { "" };

private _registry = missionNamespace getVariable ["AFCM_SIM_backendRegistry", createHashMap];
private _ids = keys _registry;

if (_ids isEqualTo []) exitWith {
    diag_log text "[AFCM-Simulator] No medical backend registered - AFCM and ACE3 are both absent. Injury-application actions will be disabled.";
    missionNamespace setVariable ["AFCM_SIM_activeBackend", "", true];
    ""
};

private _bestId = _ids select 0;
private _bestPriority = (_registry get _bestId) select 0;

{
    private _priority = (_registry get _x) select 0;
    if (_priority > _bestPriority) then {
        _bestId = _x;
        _bestPriority = _priority;
    };
} forEach _ids;

missionNamespace setVariable ["AFCM_SIM_activeBackend", _bestId, true];

diag_log text format ["[AFCM-Simulator] Active backend: %1 (priority %2, %3 candidate(s) registered locally)", _bestId, _bestPriority, count _ids];

_bestId
