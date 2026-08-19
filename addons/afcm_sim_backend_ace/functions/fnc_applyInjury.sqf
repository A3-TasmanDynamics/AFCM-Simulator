/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the applyInjury interface function.
 *
 * TODO - not yet implemented. Needs the exact ace_medical_engine hitpoint-damage entry point,
 * and the LimbId → ACE3 hitpoint mapping (DESIGN.md §4.1), confirmed against ACE3's actual source
 * before this does anything real - KAT's own wound-class internals also still need verification
 * (DESIGN.md §8 open question #1). Deliberately left as a logging stub rather than guessing an
 * ACE3 function name/signature that might be wrong.
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

diag_log text format ["[AFCM-Simulator][ACE backend] applyInjury stub called for %1 - not yet implemented, see fnc_applyInjury.sqf TODO.", _unit];
