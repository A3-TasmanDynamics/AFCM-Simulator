/*
 * Author: Tasman Dynamics
 * Adds the "Spawn Patient" interaction to an object synced/attached to an AFCM Patient module's
 * on-demand mode (fnc_module_patientPlacement.sqf's on-demand branch), run via remoteExec (target 0 =
 * everyone, JIP-persisted) same reasoning as fnc_addTerminalAction.sqf: addAction is inherently local
 * to whichever machine calls it, and ACE's interaction menu entries are the same - every client
 * (present + JIP) needs to run this itself.
 *
 * Wired per the afcm_sim_terminalInteractionMethod CBA setting (Scroll Wheel/ACE Interaction
 * Menu/Both, addons/main/functions/fnc_settings_preInit.sqf), evaluated PER CLIENT - if ACE
 * Interaction Menu is picked but ace_interact_menu isn't actually loaded on this specific machine
 * (mod mismatch), this falls back to the scroll action instead, same "don't trust every client has
 * the same mods" tolerance fnc_backend_applyInjury.sqf already applies to backend registration. No
 * real vanilla addAction submenu mechanism exists (confirmed, same reasoning fnc_addTerminalAction.sqf
 * documents) - the scroll action is deliberately flat, "AFCM:"-prefixed.
 *
 * Real, confirmed bug fixed here: the shared statement/condition code used to destructure `_this` as
 * `[_target, _caller, _actionId, _arguments]` - vanilla addAction's own shape - and pull `_logic` out
 * of `_arguments`. ACE's interaction menu calls its statement/condition with a DIFFERENT `_this` shape
 * entirely (confirmed via a real in-game RPT error: "Undefined variable in expression: _logic" inside
 * fnc_serverSpawnFromTerminal.sqf, because the value that reached it wasn't a real object at all).
 * Fixed by not depending on either API's exact `_this` shape past its first element (`_target`, the
 * one thing both addAction and ACE's interaction menu are confirmed to agree on) - `_logic` is tagged
 * directly on the target object via setVariable instead and read back the same way regardless of
 * which interaction fired, same "don't trust a stored-and-later-fired callback to see anything but
 * what's tagged on the object itself" pattern already used for the Injury Author navbar's own
 * MouseEnter/MouseExit handlers (addons/ui/functions/fnc_injuryAuthor_init.sqf).
 *
 * Label is "AFCM: <Title>" when the module's Title attribute is set, else plain "AFCM: Spawn
 * Patient" - the one place multiple placed AFCM Patient modules need to look distinct to a real
 * player, not just to whoever's editing the mission (Title's own comment, eden/config.cpp).
 *
 * Both interaction paths share one guard: the target object's own AFCM_SIM_terminalSpawned variable
 * (init'd false by fnc_module_patientPlacement.sqf, set true by fnc_serverSpawnFromTerminal.sqf once
 * a patient's actually spawned) - re-evaluated by the scroll menu/ACE menu on their own each time
 * either is opened, so the interaction disappears from both once used with no manual removal needed.
 * That guard is a UX nicety only - fnc_serverSpawnFromTerminal.sqf's own atomic check-and-set is what
 * actually prevents a double-spawn under concurrent clicks.
 *
 * Arguments:
 * 0: Object <OBJECT> - whatever the AFCM Patient module was synced/attached to
 * 1: Logic <OBJECT> - the placed AFCM_SIM_ModulePatientPlacement module itself
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_object", "_logic"];

if (isNull _object || {isNull _logic}) exitWith {};

private _title = _logic getVariable ["AFCM_SIM_title", ""];
private _label = if (_title != "") then { format ["AFCM: %1", _title] } else { "AFCM: Spawn Patient" };

// Local only (no `true`) - read back on the exact same client that's about to set it, inside the
// same interaction click, never over the network.
_object setVariable ["AFCM_SIM_terminalLogic", _logic];

private _fnc_statement = {
    params ["_target"];
    private _targetLogic = _target getVariable ["AFCM_SIM_terminalLogic", objNull];
    [_targetLogic, _target] remoteExec ["afcm_sim_eden_fnc_serverSpawnFromTerminal", 2];
};
private _fnc_condition = {
    params ["_target"];
    !(_target getVariable ["AFCM_SIM_terminalSpawned", false])
};

private _method = missionNamespace getVariable ["afcm_sim_terminalInteractionMethod", 0];
private _aceAvailable = isClass (configFile >> "CfgPatches" >> "ace_interact_menu");
private _useAce = (_method in [1, 2]) && _aceAvailable;
// Scroll Wheel or Both, OR ACE was picked but isn't actually loaded here - always leaves at least one
// working interaction on this client.
private _useScroll = (_method in [0, 2]) || !_aceAvailable;

if (_useScroll) then {
    // addAction's own statement code receives _this = [_target, _caller, _actionId, _arguments] -
    // _fnc_statement only reads the first element, so it's reused directly under either API.
    _object addAction [
        "<t color='#c1272d'>" + _label + "</t>",
        _fnc_statement,
        [],
        1.5,
        true,
        true,
        "",
        "!(_target getVariable ['AFCM_SIM_terminalSpawned', false])",
        5
    ];
};

if (_useAce) then {
    private _action = [
        "AFCM_spawnPatient",
        _label,
        "",
        _fnc_statement,
        _fnc_condition
    ] call ace_interact_menu_fnc_createAction;
    [_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
};

diag_log text format ["[AFCM-Simulator][UI] Spawn Patient interaction added to %1 (scroll=%2, ace=%3).", _object, _useScroll, _useAce];
