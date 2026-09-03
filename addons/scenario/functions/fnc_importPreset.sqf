/*
 * Author: Tasman Dynamics
 * Parses a preset previously produced by fnc_exportPreset.sqf and saves it into the calling
 * player's own user preset library (fnc_saveUserPreset.sqf) - the counterpart to export
 * (DESIGN.md §4.3). Parsing/validation itself lives in fnc_parseExportedPreset.sqf, shared with the
 * Eden AFCM Patient module's Injury Preset Import attribute - this function's own job is just the
 * "and save it to my library" part specific to the Preset Library UI.
 *
 * A fresh id is always assigned on import (never trusts the pasted id), so importing the same
 * string twice creates two separate library entries rather than silently overwriting one another
 * or colliding with a differently-sourced preset that happens to reuse an id.
 *
 * Arguments:
 * 0: Exported string <STRING> - from fnc_exportPreset.sqf
 *
 * Return Value:
 * The saved Preset <ARRAY>, or [] if the string didn't parse into a valid preset
 *
 * Public: Yes
*/

params ["_exported"];

private _cleaned = [_exported] call afcm_sim_scenario_fnc_parseExportedPreset;

if (_cleaned isEqualTo []) exitWith { [] };

_cleaned params ["_name", "_injuries", "_author", "_description", "_tags", "_katExtras"];

[_name, _injuries, _author, _description, _tags, "", _katExtras] call afcm_sim_scenario_fnc_saveUserPreset
