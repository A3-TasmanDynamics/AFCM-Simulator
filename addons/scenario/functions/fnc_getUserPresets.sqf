/*
 * Author: Tasman Dynamics
 * Returns the calling player's own saved injury presets (DESIGN.md §4.3/§ Injury Presets) - stored
 * in `profileNamespace` (real, standard SQF persistence target for per-player, per-machine saved
 * data that survives mission/game restarts, confirmed via `saveProfileNamespace`'s own real usage
 * pattern), so each player builds their own local library rather than a shared mission-scoped one.
 * Client-side only - there is no server-side concept of "the" user preset library.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Presets <ARRAY of Preset> - see fnc_getBuiltinPresets.sqf for the shape
 *
 * Public: Yes
*/

profileNamespace getVariable ["AFCM_SIM_userPresets", []]
