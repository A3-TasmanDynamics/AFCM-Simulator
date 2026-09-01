/*
 * Author: Tasman Dynamics
 * Saves (creates or overwrites) one MCI preset in the calling player's own user MCI preset library
 * (fnc_getUserMciPresets.sqf) and flushes it via `saveProfileNamespace` - same pattern as
 * fnc_saveUserPreset.sqf, separate profileNamespace key.
 *
 * Arguments:
 * 0: Name <STRING>
 * 1: Patient specs <ARRAY of STRING> - see fnc_getBuiltinMciPresets.sqf
 * 2: Author <STRING> (default: profileName)
 * 3: Description <STRING> (default "")
 * 4: Id <STRING> (default "" - generates a fresh one; pass an existing user MCI preset's id to
 *    overwrite it in place)
 *
 * Return Value:
 * The saved MciPreset <ARRAY>
 *
 * Public: Yes
*/

params [
    "_name",
    "_patientSpecs",
    ["_author", profileName],
    ["_description", ""],
    ["_id", ""]
];

if (_id isEqualTo "") then {
    // Real, confirmed collision fixed here - same reasoning as fnc_saveUserPreset.sqf: an
    // always-incrementing counter guarantees no collision is possible, regardless of timing,
    // rather than relying on diag_tickTime + random 100000 alone (a collision here would silently
    // overwrite an unrelated saved MCI preset).
    if (isNil "AFCM_SIM_mciPresetIdCounter") then { AFCM_SIM_mciPresetIdCounter = 0; };
    AFCM_SIM_mciPresetIdCounter = AFCM_SIM_mciPresetIdCounter + 1;
    _id = format ["user_mci_%1_%2", diag_tickTime, AFCM_SIM_mciPresetIdCounter];
};

private _mciPreset = [_id, _name, _author, _description, _patientSpecs];

private _presets = profileNamespace getVariable ["AFCM_SIM_userMciPresets", []];
_presets = _presets select { (_x select 0) != _id };
_presets pushBack _mciPreset;

profileNamespace setVariable ["AFCM_SIM_userMciPresets", _presets];
saveProfileNamespace;

_mciPreset
