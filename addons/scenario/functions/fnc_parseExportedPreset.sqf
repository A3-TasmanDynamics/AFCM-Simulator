/*
 * Author: Tasman Dynamics
 * Parses a string produced by fnc_exportPreset.sqf (or fnc_exportPatientState.sqf - same shape)
 * back into a cleaned [name, injuries, author, description, tags, katExtras] tuple, WITHOUT
 * touching any preset library - factored out of fnc_importPreset.sqf so a second caller (the Eden
 * AFCM Patient module's Injury Preset Import attribute, fnc_module_patientPlacement.sqf) can reuse
 * the exact same parsing/validation instead of duplicating it, since that caller applies the
 * injuries directly to one placed patient rather than saving anything to the player's own library.
 *
 * katExtras is the Preset shape's optional 7th element (fnc_exportPatientState.sqf -
 * `[fractures <ARRAY[6]>, pneumothoraxType, airwayType, cardiacRhythm]`) - absent on every
 * built-in/older preset, which is why a preset is still considered valid with only a name plus
 * EITHER a non-empty injuries array OR a non-default katExtras (not neither) - a patient exported
 * with just a cardiac arrest and no base wound is a real, valid export on its own.
 *
 * `call compile` on pasted/authored text only ever runs on whichever machine calls this (the
 * importing player's own client for the Preset Library, the server for an Eden module attribute at
 * mission init) - same trust level either already has over their own client/mission file, not a
 * new attack surface. Malformed/non-preset input is rejected ([]) rather than trusted.
 *
 * Arguments:
 * 0: Exported string <STRING>
 *
 * Return Value:
 * [name <STRING>, injuries <ARRAY of [limb, woundType, severity, bleeding]>, author <STRING>,
 *  description <STRING>, tags <ARRAY of STRING>, katExtras <ARRAY>], or [] if the string didn't
 *  parse into a valid preset. katExtras is [] when the source preset had none/an invalid one.
 *
 * Public: Yes
*/

params ["_exported"];

if (_exported isEqualTo "") exitWith { [] };

// No try/catch in vanilla SQF - genuinely malformed (non-array) input surfaces as an RPT script
// error from `call compile` rather than failing silently, an acceptable outcome for text a human
// pasted/typed in (same class of risk as the debug console).
private _parsed = call compile _exported;

if (typeName _parsed != "ARRAY" || {count _parsed < 5}) exitWith { [] };

_parsed params [["_id", "", [""]], ["_name", "", [""]], ["_author", "", [""]], ["_description", "", [""]], ["_injuries", [], [[]]], ["_tags", [], [[]]], ["_katExtras", [], [[]]]];

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

private _cleanKatExtras = [];
if (count _katExtras == 4) then {
    _katExtras params [["_fractures", [], [[]]], ["_pneumoType", 0], ["_airwayType", 0], ["_rhythm", 0]];
    private _fracturesValid = (_fractures isEqualType []) && {count _fractures == 6} && {(_fractures select { typeName _x != "SCALAR" }) isEqualTo []};
    if (_fracturesValid && {typeName _pneumoType == "SCALAR"} && {typeName _airwayType == "SCALAR"} && {typeName _rhythm == "SCALAR"}) then {
        _cleanKatExtras = [_fractures, _pneumoType, _airwayType, _rhythm];
    };
};

if (_cleanInjuries isEqualTo [] && {_cleanKatExtras isEqualTo []}) exitWith { [] };

[_name, _cleanInjuries, _author, _description, _tags, _cleanKatExtras]
