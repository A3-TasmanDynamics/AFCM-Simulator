/*
 * Author: Tasman Dynamics
 * Returns the calling player's own saved MCI presets - stored in `profileNamespace` under a
 * separate key from single-injury Presets (AFCM_SIM_userMciPresets vs AFCM_SIM_userPresets), same
 * per-player/per-machine persistence reasoning as fnc_getUserPresets.sqf.
 *
 * Filters out any entry that isn't a real, well-formed MciPreset before returning - same real,
 * confirmed gap fix as fnc_getUserPresets.sqf: profileNamespace is user-editable/persistent data,
 * and every consumer of this list does an unguarded `_x select 0` on whatever comes back.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * MciPresets <ARRAY of MciPreset> - see fnc_getBuiltinMciPresets.sqf for the shape
 *   ([id, name, author, description, patientSpecs], id/name/author/description Strings)
 *
 * Public: Yes
*/

(profileNamespace getVariable ["AFCM_SIM_userMciPresets", []]) select {
    (typeName _x == "ARRAY")
    && {count _x >= 5}
    && {typeName (_x select 0) == "STRING"}
    && {(_x select 0) != ""}
}
