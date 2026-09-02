/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the applyInjury interface function.
 *
 * Thin dispatcher - the real work lives in the shared afcm_sim_main_fnc_medical_
 * applyAceStyleInjuryLocal (kat_compat's own fnc_applyInjury.sqf calls the exact same shared
 * function, since KAT extends ACE3's own wound pipeline rather than replacing it, KAT_COMPAT.md
 * §3 - the two used to be byte-for-byte duplicated copies of this logic). Dispatched via
 * CBA_fnc_targetEvent rather than called directly: `ace_medical_fnc_addDamageToUnit` requires
 * `local _unit` (REFERENCES.md, confirmed directly from ACE3's own source), but this function is
 * reached from a server-authoritative remoteExec (DESIGN.md §6) with no guarantee the target unit
 * is actually local to the server - CBA_fnc_targetEvent (real, confirmed from CBATeam/CBA_A3's own
 * source) runs the registered event's handler on whichever machine the target really is local to,
 * same real mechanism KAT's own source uses for the same class of problem (its "...Local"-suffixed
 * treatment functions, e.g. fnc_treatmentAdvanced_airway.sqf).
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Injury <HASHMAP> - see DESIGN.md §4.2
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_injury"];

if (isNull _unit) exitWith {};

["afcm_sim_applyAceStyleInjuryLocal", [_unit, _injury, "ACE"], _unit] call CBA_fnc_targetEvent;
