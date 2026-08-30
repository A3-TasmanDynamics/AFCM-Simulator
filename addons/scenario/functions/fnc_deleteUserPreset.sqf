/*
 * Author: Tasman Dynamics
 * Removes one preset from the calling player's own user preset library by id and flushes the
 * change via `saveProfileNamespace`. Built-in presets (id prefix "builtin_") can't be deleted -
 * the Preset Library UI never offers this action for them, but this function guards it too.
 *
 * Arguments:
 * 0: Id <STRING>
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_id"];

if (_id find "builtin_" == 0) exitWith {};

private _presets = profileNamespace getVariable ["AFCM_SIM_userPresets", []];
_presets = _presets select { (_x select 0) != _id };

profileNamespace setVariable ["AFCM_SIM_userPresets", _presets];
saveProfileNamespace;
