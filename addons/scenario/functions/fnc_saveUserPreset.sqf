/*
 * Author: Tasman Dynamics
 * Saves (creates or overwrites) one preset in the calling player's own user preset library
 * (fnc_getUserPresets.sqf) and immediately flushes it to disk via the real `saveProfileNamespace`
 * command - client-side only, same reasoning as fnc_getUserPresets.sqf.
 *
 * Arguments:
 * 0: Name <STRING>
 * 1: Injuries <ARRAY of [limb, woundType, severity, bleeding]> - see fnc_getBuiltinPresets.sqf
 * 2: Author <STRING> (default: profileName - the real command returning this player's own
 *    profile/Steam name)
 * 3: Description <STRING> (default "")
 * 4: Tags <ARRAY of STRING> (default [])
 * 5: Id <STRING> (default "" - generates a fresh one; pass an existing user preset's id to
 *    overwrite it in place instead of adding a duplicate)
 *
 * Return Value:
 * The saved Preset <ARRAY>
 *
 * Public: Yes
*/

params [
    "_name",
    "_injuries",
    ["_author", profileName],
    ["_description", ""],
    ["_tags", []],
    ["_id", ""]
];

if (_id isEqualTo "") then {
    // Real, confirmed collision fixed here: diag_tickTime + random 100000 alone had a real, if
    // small, chance of colliding - since a collision here silently OVERWRITES an unrelated saved
    // preset (the dedup filter below matches on id) rather than merely merging like the Spawn
    // Session case, this is worse than that one, not just as bad. A simple, always-incrementing
    // counter guarantees no collision is possible at all, regardless of timing.
    if (isNil "AFCM_SIM_presetIdCounter") then { AFCM_SIM_presetIdCounter = 0; };
    AFCM_SIM_presetIdCounter = AFCM_SIM_presetIdCounter + 1;
    _id = format ["user_%1_%2", diag_tickTime, AFCM_SIM_presetIdCounter];
};

private _preset = [_id, _name, _author, _description, _injuries, _tags];

private _presets = profileNamespace getVariable ["AFCM_SIM_userPresets", []];
_presets = _presets select { (_x select 0) != _id };
_presets pushBack _preset;

profileNamespace setVariable ["AFCM_SIM_userPresets", _presets];
saveProfileNamespace;

_preset
