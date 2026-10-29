/*
 * Author: Tasman Dynamics
 * The real, shared blood volume/SpO2 write both ace_compat and kat_compat use - KAT extends these
 * same two ACE3 variables rather than owning separate ones (confirmed: both backends' own
 * fnc_getState.sqf read identical `ace_medical_bloodVolume`/`ace_medical_spo2` getVariable calls,
 * addons/ace_compat/functions/fnc_getState.sqf, addons/kat_compat/functions/fnc_getState.sqf), so
 * one shared implementation covers both rather than two duplicated copies.
 *
 * Dispatched via CBA_fnc_targetEvent, not called directly - same locality reasoning as
 * fnc_medical_applyAceStyleInjuryLocal.sqf: this is reached from a server-authoritative remoteExec
 * (DESIGN.md §6) with no guarantee the target unit is actually local to the server, and a
 * `setVariable` with global effect still needs to originate from the unit's own owning machine for
 * ACE's own local-tracking logic elsewhere to see a consistent value immediately rather than only
 * after the next replication tick.
 *
 * Pain (ace_medical_pain, 0-1, same real variable afcm_sim_ace_compat/kat_compat's own
 * fnc_getState.sqf already reads - REFERENCES.md) folded into this same setVitals op rather than a
 * separate interface function, on request ("be able to select pain level... same as [blood/SpO2]").
 *
 * Arguments (from CBA_fnc_targetEvent, matching its real _params-becomes-_this shape):
 * 0: Target unit <OBJECT>
 * 1: Blood volume <NUMBER> - litres
 * 2: SpO2 <NUMBER> - percent
 * 3: Pain <NUMBER> - 0-1
 * 4: Backend label <STRING> - "ACE" or "KAT", for logging only
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_bloodVolume", "_spo2", "_pain", ["_backendLabel", "ACE"]];

if (isNull _unit) exitWith {};

_unit setVariable ["ace_medical_bloodVolume", _bloodVolume, true];
_unit setVariable ["ace_medical_spo2", _spo2, true];
_unit setVariable ["ace_medical_pain", _pain, true];

diag_log text format ["[AFCM-Simulator][%1 backend] setVitals - %2 bloodVolume=%3 spO2=%4 pain=%5.", _backendLabel, _unit, _bloodVolume, _spo2, _pain];
