/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleEditInjuries (Zeus). Drag this module directly onto any unit
 * in the Zeus interface (curatorCanAttach=1, zeus/config.cpp) to open the Injury Editor for that
 * unit immediately, same limb-select -> injury-editor flow the "Edit Injuries" scroll action opens
 * (afcm_sim_ui_fnc_limbSelect_open) - just reachable without needing that addAction to already
 * exist on the target, so it also works on units afcm_sim_spawner_fnc_spawnPatient never touched.
 *
 * Real, confirmed "drop directly onto a unit" pattern, grounded in ACE3's own Zeus module source
 * (acemod/ACE3, addons/zeus/fnc_moduleHeal.sqf - the same mechanism ACE3's own "Heal" Zeus module
 * uses):
 * - The target unit comes from `attachedTo _logic`, NOT the `_units` (synced units) param -
 *   attaching (curatorCanAttach) is a distinct mechanism from syncing.
 * - `isGlobal = 1` still broadcasts this function call to every connected machine, same as every
 *   other AFCM module - `if !(local _logic) exitWith {};` is what actually restricts opening the
 *   dialog to just the curator's own machine (the one _logic is local to), so it doesn't pop open
 *   on every other connected client's screen too.
 * - One-shot: deletes itself (`deleteVehicle _logic`) once used, rather than staying a persistent
 *   placed object - there's nothing left for it to do after the dialog opens.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed/attached module
 * 1: Units <ARRAY> - synced units, if any (unused here - the target comes from attachedTo, not this)
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_logic", "_units", "_activated"];

if !(_activated) exitWith {};
if !(local _logic) exitWith {};

private _unit = attachedTo _logic;

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {
    hint "AFCM: Edit Injuries must be dropped directly onto a person.";
    deleteVehicle _logic;
};

[_unit] call afcm_sim_ui_fnc_limbSelect_open;

deleteVehicle _logic;
