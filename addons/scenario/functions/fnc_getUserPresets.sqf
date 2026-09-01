/*
 * Author: Tasman Dynamics
 * Returns the calling player's own saved injury presets (DESIGN.md §4.3/§ Injury Presets) - stored
 * in `profileNamespace` (real, standard SQF persistence target for per-player, per-machine saved
 * data that survives mission/game restarts, confirmed via `saveProfileNamespace`'s own real usage
 * pattern), so each player builds their own local library rather than a shared mission-scoped one.
 * Client-side only - there is no server-side concept of "the" user preset library.
 *
 * Filters out any entry that isn't a real, well-formed Preset before returning - real, confirmed
 * gap fixed here: profileNamespace is user-editable/persistent data (a hand-edited .Arma3Profile,
 * disk corruption, or a future format change could all leave a malformed entry behind), and every
 * consumer of this list (fnc_findPreset.sqf, fnc_saveUserPreset.sqf/deleteUserPreset.sqf's own
 * dedup filters, fnc_importPreset.sqf's id-collision check) does an unguarded `_x select 0` on
 * whatever comes back - one bad entry used to break reading, saving, deleting, AND importing
 * presets simultaneously, not just fail to load gracefully. Sanitizing at this one source means
 * every downstream consumer gets clean data without needing its own guard.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Presets <ARRAY of Preset> - see fnc_getBuiltinPresets.sqf for the shape
 *   ([id, name, author, description, injuries, tags], id/name/author/description Strings)
 *
 * Public: Yes
*/

(profileNamespace getVariable ["AFCM_SIM_userPresets", []]) select {
    (typeName _x == "ARRAY")
    && {count _x >= 6}
    && {typeName (_x select 0) == "STRING"}
    && {(_x select 0) != ""}
}
