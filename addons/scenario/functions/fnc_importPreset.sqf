/*
 * Author: Tasman Dynamics
 * Parses a preset previously produced by fnc_exportPreset.sqf back into a Preset array and saves
 * it into the calling player's own user preset library (fnc_saveUserPreset.sqf) - the counterpart
 * to export (DESIGN.md §4.3).
 *
 * A fresh id is always assigned on import (never trusts the pasted id), so importing the same
 * string twice creates two separate library entries rather than silently overwriting one another
 * or colliding with a differently-sourced preset that happens to reuse an id.
 *
 * `call compile` on pasted text only ever runs on the importing player's own client, and only the
 * resulting plain-data values (never re-compiled code) go anywhere from there - the same trust
 * level as that player already has over their own client via the debug console, not a new attack
 * surface. Malformed/non-preset paste input is rejected (returns []) rather than trusted.
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

if (_exported isEqualTo "") exitWith { [] };

// No try/catch in vanilla SQF - genuinely malformed (non-array) paste input surfaces as an RPT
// script error from `call compile` rather than failing silently, which is an acceptable outcome
// for a local, player-initiated paste action (same class of risk as typing into the debug console).
private _parsed = call compile _exported;

if (typeName _parsed != "ARRAY" || {count _parsed < 5}) exitWith { [] };

_parsed params [["_id", "", [""]], ["_name", "", [""]], ["_author", "", [""]], ["_description", "", [""]], ["_injuries", [], [[]]], ["_tags", [], [[]]]];

if (_name isEqualTo "" || {typeName _injuries != "ARRAY"}) exitWith { [] };

// Keep only well-formed injury entries rather than reject the whole preset over one bad one.
private _validLimbs = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"];
private _cleanInjuries = _injuries select {
    (_x isEqualType []) &&
    {count _x >= 4} &&
    {(_x select 0) in _validLimbs} &&
    {typeName (_x select 1) == "STRING"} &&
    {typeName (_x select 2) == "SCALAR"} &&
    {typeName (_x select 3) == "BOOL"}
};

if (_cleanInjuries isEqualTo []) exitWith { [] };

[_name, _cleanInjuries, _author, _description, _tags] call afcm_sim_scenario_fnc_saveUserPreset
