/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the setVitals interface function.
 *
 * Thin dispatcher - the real work lives in the shared afcm_sim_main_fnc_medical_setVitalsLocal
 * (kat_compat's own fnc_setVitals.sqf calls the exact same shared function, since KAT extends
 * these same two ACE3 variables rather than owning separate ones). Dispatched via
 * CBA_fnc_targetEvent rather than called directly, same locality reasoning as this addon's own
 * fnc_applyInjury.sqf.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Blood volume <NUMBER> - litres
 * 2: SpO2 <NUMBER> - percent
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_bloodVolume", "_spo2"];

if (isNull _unit) exitWith {};

["afcm_sim_setVitalsLocal", [_unit, _bloodVolume, _spo2, "ACE"], _unit] call CBA_fnc_targetEvent;
