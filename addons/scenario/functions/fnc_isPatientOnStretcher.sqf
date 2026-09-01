/*
 * Author: Tasman Dynamics
 * True if the given unit is within range of any registered Medical Tent stretcher.
 *
 * Arguments:
 * 0: Patient unit <OBJECT>
 * 1: Stretchers <ARRAY> - AFCM_SIM_medicalStretchers, an Array of [stretcher <OBJECT>, radius
 *    <NUMBER>] pairs (fnc_registerMedicalTent.sqf)
 *
 * Return Value:
 * Bool
 *
 * Public: No
*/

params ["_unit", "_stretchers"];

if (isNull _unit) exitWith { false };

(_stretchers findIf {
    (_x select 0) distance _unit < (_x select 1)
}) != -1
