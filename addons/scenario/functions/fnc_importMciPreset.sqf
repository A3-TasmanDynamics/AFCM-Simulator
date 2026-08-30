/*
 * Author: Tasman Dynamics
 * Parses an MCI preset previously produced by fnc_exportMciPreset.sqf back into an MciPreset array
 * and saves it into the calling player's own user MCI preset library
 * (fnc_saveUserMciPreset.sqf) - counterpart to export, same trust/validation reasoning as
 * fnc_importPreset.sqf (only ever runs client-side on the importing player's own machine; a fresh
 * id is always assigned, never the pasted one).
 *
 * Patient specs that don't resolve to either "random" or a real, currently-known Preset id are
 * dropped rather than rejecting the whole import - a shared preset string might reference a user
 * preset the importing player doesn't have saved themselves, which is a real, expected case, not
 * corruption.
 *
 * Arguments:
 * 0: Exported string <STRING> - from fnc_exportMciPreset.sqf
 *
 * Return Value:
 * The saved MciPreset <ARRAY>, or [] if the string didn't parse into a valid MCI preset
 *
 * Public: Yes
*/

params ["_exported"];

if (_exported isEqualTo "") exitWith { [] };

private _parsed = call compile _exported;

if (typeName _parsed != "ARRAY" || {count _parsed < 5}) exitWith { [] };

_parsed params [["_id", "", [""]], ["_name", "", [""]], ["_author", "", [""]], ["_description", "", [""]], ["_patientSpecs", [], [[]]]];

if (_name isEqualTo "" || {typeName _patientSpecs != "ARRAY"}) exitWith { [] };

private _knownIds = ((call afcm_sim_scenario_fnc_getBuiltinPresets) + (call afcm_sim_scenario_fnc_getUserPresets)) apply { _x select 0 };
private _cleanSpecs = _patientSpecs select { (typeName _x == "STRING") && {_x == "random" || {_x in _knownIds}} };

if (_cleanSpecs isEqualTo []) exitWith { [] };

[_name, _cleanSpecs, _author, _description] call afcm_sim_scenario_fnc_saveUserMciPreset
