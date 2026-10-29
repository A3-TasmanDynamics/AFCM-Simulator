/*
 * Author: Tasman Dynamics
 * Resolves AFCM_SIM_ModuleInteractiveTerminal's actual target object (synced unit, or Zeus
 * attachedTo), retrying every 1s for up to 5 attempts before giving up - factored out of
 * fnc_module_interactiveTerminal.sqf so it can call itself by name (CBA_fnc_waitAndExecute) rather
 * than stash an ad-hoc self-referencing closure in missionNamespace.
 *
 * A single fixed-delay check isn't a guaranteed-safe margin on every server (load, mission
 * complexity, a slower dedicated server all push replication further out) - a curator dragging the
 * module onto an object in Zeus could see it silently never add its actions. Retrying gives
 * replication real room to catch up instead of a one-shot gamble. Every attempt is unconditionally
 * diag_log'd (not gated behind Debug Logging) - temporary, specifically so a retest pins down
 * exactly which stage fails if this still isn't enough.
 *
 * Real, confirmed enforcement added on request ("must be placed on an object... icon disappears
 * once placed"): the module logic itself is now deleted on success (its job - adding the real
 * terminal actions to the target object - is done, same "nothing left for the module object to do"
 * reasoning AFCM_SIM_ModuleMciSpawner/ModuleEditInjuries already self-delete for) AND on final
 * failure (an operator who places/drops it with nothing synced or attached gets a module that
 * quietly cleans itself up rather than lingering as a dead, non-functional icon - the real
 * enforcement mechanism, since Arma's own placement UI has no way to outright refuse an
 * unattached/unsynced placement). Deletion runs here (server-authoritative, same gate this whole
 * resolve chain already runs under) rather than gated on `local _logic` the way the self-standing
 * Zeus-only modules are - deleteVehicle issued by the server reliably removes any object regardless
 * of which client it's local to.
 *
 * Also real-hints the placing curator both ways now, on request - success ("the object is now set
 * as a Medical Terminal") and final failure ("must be placed on an object"), remoteExec'd to
 * `_ownerId` since this whole chain runs server-side and the curator may be on a different machine
 * entirely in dedicated MP.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed/attached module
 * 1: Units <ARRAY> - synced units; first entry (if any) is the target object
 * 2: Attempt <NUMBER> - 1-indexed, gives up after attempt 5
 * 3: Owner id <NUMBER> - the real client id of whichever curator placed this (`owner _logic`),
 *    passed through every retry so the final hint still reaches them
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_logic", "_units", "_attempt", "_ownerId"];

if (isNull _logic) exitWith {};

private _object = _units param [0, objNull];
if (isNull _object) then { _object = attachedTo _logic; };

diag_log text format ["[AFCM-Simulator][Eden][diag] Medical Terminal resolve attempt %1/5 - object=%2.", _attempt, _object];

if !(isNull _object) exitWith {
    _logic setVariable ["AFCM_SIM_moduleFired", true];
    [_object] remoteExec ["afcm_sim_ui_fnc_addTerminalAction", 0, true];
    ["AFCM Medical Terminal", "This object is now set as a Medical Terminal."] remoteExec ["afcm_sim_ui_fnc_showToast", _ownerId];
    deleteVehicle _logic;
};

if (_attempt < 5) then {
    [afcm_sim_eden_fnc_resolveTerminalTarget, [_logic, _units, _attempt + 1, _ownerId], 1] call CBA_fnc_waitAndExecute;
} else {
    diag_log text "[AFCM-Simulator][Eden] Medical Terminal module gave up after 5s - still no synced/attached object, deleting (must be placed on an object).";
    ["AFCM Medical Terminal", "Must be placed directly on an object - nothing was synced or attached."] remoteExec ["afcm_sim_ui_fnc_showToast", _ownerId];
    deleteVehicle _logic;
};
