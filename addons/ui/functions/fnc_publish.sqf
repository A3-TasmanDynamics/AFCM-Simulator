/*
 * Author: Tasman Dynamics
 * Publishes an event on the AFCM-Simulator UI event bus (DESIGN.md §3). Calls every handler
 * subscribed via afcm_sim_ui_fnc_subscribe, passing _params as their _this.
 *
 * Arguments:
 * 0: Event name <STRING> - e.g. "limb.selected"
 * 1: Params <ARRAY> (default [])
 *
 * Return Value:
 * None
 *
 * Example:
 * ["limb.selected", ["head"]] call afcm_sim_ui_fnc_publish
 *
 * Public: Yes
*/

params ["_eventName", ["_params", []]];

private _subscribers = missionNamespace getVariable ["AFCM_SIM_UI_eventBus", createHashMap];
private _handlers = _subscribers get _eventName;

if (isNil "_handlers") exitWith {};

{ _params call _x } forEach _handlers;
