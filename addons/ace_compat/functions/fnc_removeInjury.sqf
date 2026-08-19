/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the removeInjury interface function.
 *
 * TODO - not yet implemented, same reasoning as fnc_applyInjury.sqf.
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

diag_log text format ["[AFCM-Simulator][ACE backend] removeInjury stub called for %1 - not yet implemented, see fnc_removeInjury.sqf TODO.", _unit];
