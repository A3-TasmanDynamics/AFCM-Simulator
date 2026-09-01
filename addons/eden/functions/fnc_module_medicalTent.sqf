/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleMedicalTent (Eden). Registers every stretcher object synced
 * to this module (`_units`) into the shared Medical Tent completion monitor
 * (afcm_sim_scenario_fnc_registerMedicalTent) at the module's own Stretcher Radius attribute - see
 * eden/config.cpp for the full design (mission maker builds the physical tent themselves out of
 * real objects/a Composition; AFCM only tracks which objects are stretchers).
 *
 * Server-only, like every other AFCM module here - registration only needs to happen once, on the
 * single machine (the server) that will actually run the completion monitor
 * (afcm_sim_scenario_fnc_startMedicalTentMonitor), same isServer/moduleFired guard pattern as
 * AFCM_SIM_ModuleInteractiveTerminal.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed module
 * 1: Units <ARRAY of OBJECT> - synced stretcher objects
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_logic", "_units", "_activated"];

if !(_activated) exitWith {};
if !(isServer) exitWith {};
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};
_logic setVariable ["AFCM_SIM_moduleFired", true];

private _radius = _logic getVariable ["AFCM_SIM_stretcherRadius", 2];

[_units, _radius] call afcm_sim_scenario_fnc_registerMedicalTent;
