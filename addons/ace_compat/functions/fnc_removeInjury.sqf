/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the removeInjury interface function.
 *
 * TODO - not yet implemented, same reasoning as fnc_applyInjury.sqf.
 *
 * Returns false, not just logging and falling off the end - afcm_sim_fnc_backend_removeInjury's own
 * contract is "true if the active backend handled it" (real, confirmed gap this fixes: it used to
 * always return true once ANY function existed to call, even this literal no-op stub, so a caller
 * trusting that return value to report success to an instructor would be told "removed" on every
 * call today).
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Injury <HASHMAP> - see DESIGN.md §4.2
 *
 * Return Value:
 * Bool - always false, this is a stub
 *
 * Public: No
*/

params ["_unit", "_injury"];

diag_log text format ["[AFCM-Simulator][ACE backend] removeInjury stub called for %1 - not yet implemented, see fnc_removeInjury.sqf TODO.", _unit];

false
