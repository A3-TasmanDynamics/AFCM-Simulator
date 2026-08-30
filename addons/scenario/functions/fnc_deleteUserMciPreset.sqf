/*
 * Author: Tasman Dynamics
 * Removes one MCI preset from the calling player's own user library by id and flushes the change
 * via `saveProfileNamespace`. Built-in MCI presets (id prefix "builtin_mci_") can't be deleted -
 * same guard pattern as fnc_deleteUserPreset.sqf.
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

private _presets = profileNamespace getVariable ["AFCM_SIM_userMciPresets", []];
_presets = _presets select { (_x select 0) != _id };

profileNamespace setVariable ["AFCM_SIM_userMciPresets", _presets];
saveProfileNamespace;
