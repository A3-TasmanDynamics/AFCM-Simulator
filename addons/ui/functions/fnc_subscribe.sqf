/*
 * Author: Tasman Dynamics
 * Subscribes to an event on the AFCM-Simulator UI event bus (DESIGN.md §3). Decouples "UI raised
 * an intent" from "domain logic executed it" — afcm_sim_scenario/afcm_sim_spawner subscribe here
 * rather than dialogs calling their functions directly, so a future Phase-2 overlay frontend
 * (DESIGN.md §2.3/§2.4) could publish onto the same bus without this side changing at all.
 *
 * Arguments:
 * 0: Event name <STRING> - e.g. "limb.selected"
 * 1: Handler <CODE> - called with the event's params array as _this
 *
 * Return Value:
 * None
 *
 * Example:
 * ["limb.selected", { params ["_limbIds"]; ... }] call afcm_sim_ui_fnc_subscribe
 *
 * Public: Yes
*/

params ["_eventName", "_handler"];

private _subscribers = missionNamespace getVariable ["AFCM_SIM_UI_eventBus", createHashMap];
private _handlers = _subscribers getOrDefault [_eventName, [], true];
_handlers pushBack _handler;

missionNamespace setVariable ["AFCM_SIM_UI_eventBus", _subscribers];
