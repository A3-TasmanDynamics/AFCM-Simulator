/*
 * Author: Tasman Dynamics
 * KAT - Advanced Medical backend implementation of the applyInjury interface function.
 *
 * Thin dispatcher - real implementation identical in substance to afcm_sim_ace_compat's (confirmed
 * directly from KAT's own source, KAT_COMPAT.md §3, that KAT registers additional wound handlers
 * into ACE3's own real `ACE_Medical_Injuries` config tree rather than replacing ACE3's damage-
 * application API - so the same two real ACE3 calls apply correctly under KAT too, with KAT's own
 * systems triggering automatically as a side effect). Both backends now call the exact same shared
 * afcm_sim_main_fnc_medical_applyAceStyleInjuryLocal rather than each keeping its own copy of that
 * logic (they used to be byte-for-byte duplicated).
 *
 * Dispatched via CBA_fnc_targetEvent, not called directly - same real fix as afcm_sim_ace_compat's
 * own fnc_applyInjury.sqf: `ace_medical_fnc_addDamageToUnit` requires `local _unit`
 * (REFERENCES.md), and this function is reached from a server-authoritative remoteExec with no
 * guarantee the target unit is actually local to the server. See fnc_medical_
 * applyAceStyleInjuryLocal.sqf's own header (afcm_sim_main) for the full explanation.
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

["afcm_sim_applyAceStyleInjuryLocal", [_unit, _injury, "KAT"], _unit] call CBA_fnc_targetEvent;
