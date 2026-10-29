/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleMciSpawner (Zeus). Real, confirmed request/redesign: placing
 * this module used to immediately spawn a batch of clean, unconscious patients at that position and
 * add an "Assign MCI Preset" scroll action to the batch (opening the single-injury Preset Library in
 * batch mode - one shared wound for everyone, no per-patient variety). Operators wanted the actual
 * MCI Creator (RscDisplayAFCM_SIM_MciCreator) instead - per-patient preset assignment, Load MCI
 * Preset for a real saved incident, the works - just skipping its own "Choose Location on Map" step
 * since placing this module here already picked the spot.
 *
 * `local _logic` (not isServer, unlike this module's old behaviour) is what makes that possible -
 * `isGlobal = 1` still broadcasts this call to every connected machine, but only the placing
 * curator's own machine ever sees `local _logic` as true, so the dialog only ever pops up for
 * them - same real, confirmed-working pattern AFCM_SIM_ModuleEditInjuries already uses
 * (zeus/functions/fnc_module_editInjuries.sqf, grounded in ACE3's own Zeus "Heal" module source) for
 * exactly this "which one client's curator placed it" problem. One-shot: self-deletes right after
 * opening the dialog, same as Edit Injuries - there's nothing left for the module object itself to
 * do once the dialog's up, and the dialog is independently reachable afterward (Ctrl+Shift+M) if the
 * operator wants to come back to it.
 *
 * AFCM_SIM_UI_mciLocation is pre-set to this module's own placement position before opening -
 * fnc_mciCreator_refreshLocationStatus.sqf (called from the dialog's own onLoad) picks that straight
 * up, enabling Spawn MCI immediately with no location-picking step forced on the operator. They can
 * still click "Choose Location on Map" afterward to override it if they want to fine-tune the spot.
 *
 * The module's own Patient Count/Casualty Type Attributes still matter, just differently now:
 * Casualty Type always seeds AFCM_SIM_UI_mciCasualtyType fresh (low-stakes, visible, freely
 * correctable right there in the dialog). Patient Count only seeds a fresh
 * AFCM_SIM_UI_mciPatientSpecs (same `isNil` guard fnc_mciCreator_init.sqf's own default-3 behaviour
 * already uses) - deliberately never overwrites an in-progress MCI Creator session from earlier this
 * same mission (Ctrl+Shift+M or a previous module placement), matching that dialog's own documented
 * "reopening keeps whatever was last configured" philosophy.
 *
 * Also guards against firing more than once per placed module (`AFCM_SIM_moduleFired`, a variable
 * stashed on `_logic` itself) - vanilla Module_F's function has no guaranteed single-fire
 * behaviour (confirmed independently by ACE3's own Modules Framework docs, which built their own
 * wrapper specifically because "there is no guarantee" here) - kept even though `deleteVehicle`
 * below also prevents a genuine re-fire, since the two broadcast calls could in principle land in
 * the same frame before the first `deleteVehicle` takes effect.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed module
 * 1: Units <ARRAY> - synced units, if any (unused)
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_logic", "_units", "_activated"];

// Diagnostic-only, temporary - see fnc_module_spawnRandomPatient.sqf's own comment for why. Logs
// `local _logic` (not isServer, which PR #56 originally logged here before this module's own
// redesign changed its real guard to match Edit Injuries' local-client pattern).
diag_log text format ["[AFCM-Simulator][Zeus][diag] MCI Spawner module fired - activated=%1, local=%2, moduleFired=%3.", _activated, local _logic, _logic getVariable ["AFCM_SIM_moduleFired", false]];

if !(_activated) exitWith {};
if !(local _logic) exitWith {};
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};
_logic setVariable ["AFCM_SIM_moduleFired", true];

private _patientCount = _logic getVariable ["AFCM_SIM_patientCount", 4];
private _casualtyType = _logic getVariable ["AFCM_SIM_casualtyType", afcm_sim_defaultCasualtyType];
private _radius = _logic getVariable ["AFCM_SIM_radius", 10];

missionNamespace setVariable ["AFCM_SIM_UI_mciLocation", getPosASL _logic];
missionNamespace setVariable ["AFCM_SIM_UI_mciCasualtyType", _casualtyType];
// Same "always seeds fresh" reasoning as Casualty Type above (low-stakes, visible, freely
// correctable right there in the Map Picker's own Radius field) - not gated behind an isNil guard
// the way Patient Count's mciPatientSpecs is.
missionNamespace setVariable ["AFCM_SIM_UI_mciRadius", _radius];
if (isNil "AFCM_SIM_UI_mciPatientSpecs") then {
    private _specs = [];
    for "_i" from 1 to _patientCount do { _specs pushBack "random"; };
    AFCM_SIM_UI_mciPatientSpecs = _specs;
};

call afcm_sim_ui_fnc_mciCreator_open;

deleteVehicle _logic;
