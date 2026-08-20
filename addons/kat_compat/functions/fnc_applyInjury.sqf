/*
 * Author: Tasman Dynamics
 * KAT - Advanced Medical backend implementation of the applyInjury interface function.
 *
 * TODO - not yet implemented. KAT's real repo/docs are now confirmed (REFERENCES.md) — prefix
 * "kat_", built on ace_medical_engine, real item classes like kat_bloodIV_A, kat_AED, kat_ketamine
 * confirmed — but the actual wound/injury-application entry point (KAT's equivalent of
 * ace_medical_fnc_addDamageToUnit) isn't confirmed yet, only two adjacent pieces from a prior
 * working script: kat_surgery_fractures (a 6-element per-limb array) and
 * kat_breathing_fnc_handleBreathing (applies kat_breathing_* variables after they're set).
 * Deliberately left as a logging stub rather than guessing the actual damage/wound call.
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

diag_log text format ["[AFCM-Simulator][KAT backend] applyInjury stub called for %1 - not yet implemented, see fnc_applyInjury.sqf TODO.", _unit];
