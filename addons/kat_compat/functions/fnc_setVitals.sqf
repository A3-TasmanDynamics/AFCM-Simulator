/*
 * Author: Tasman Dynamics
 * KAT - Advanced Medical backend implementation of the setVitals interface function.
 *
 * Thin dispatcher - identical in substance to afcm_sim_ace_compat's own fnc_setVitals.sqf, both
 * calling the exact same shared afcm_sim_main_fnc_medical_setVitalsLocal (KAT extends these same
 * two ACE3 variables, ace_medical_bloodVolume/ace_medical_spo2, rather than owning separate ones -
 * confirmed from both backends' own fnc_getState.sqf reading identical getVariable calls).
 * Dispatched via CBA_fnc_targetEvent, same locality reasoning as this addon's own
 * fnc_applyInjury.sqf.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Blood volume <NUMBER> - litres
 * 2: SpO2 <NUMBER> - percent
 * 3: Pain <NUMBER> - 0-1
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_bloodVolume", "_spo2", "_pain"];

if (isNull _unit) exitWith {};

["afcm_sim_setVitalsLocal", [_unit, _bloodVolume, _spo2, _pain, "KAT"], _unit] call CBA_fnc_targetEvent;
