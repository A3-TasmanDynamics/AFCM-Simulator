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
    _id = format ["user_%1_%2", diag_tickTime, floor (random 100000)];
};

private _preset = [_id, _name, _author, _description, _injuries, _tags];

private _presets = profileNamespace getVariable ["AFCM_SIM_userPresets", []];
_presets = _presets select { (_x select 0) != _id };
_presets pushBack _preset;

profileNamespace setVariable ["AFCM_SIM_userPresets", _presets];
saveProfileNamespace;

_preset
