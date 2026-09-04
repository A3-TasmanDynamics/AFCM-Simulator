/*
 * Author: Tasman Dynamics
 * Parses an exported string back into a cleaned [name, injuries, author, description, tags,
 * katExtras] tuple, WITHOUT touching any preset library - factored out of fnc_importPreset.sqf so
 * a second caller (the Eden AFCM Patient module's Injury Preset Import attribute,
 * fnc_module_patientPlacement.sqf) can reuse the exact same parsing/validation instead of
 * duplicating it, since that caller applies the injuries directly to one placed patient rather
 * than saving anything to the player's own library.
 *
 * Accepts TWO real export shapes, told apart by element count:
 *  - Full Preset envelope (fnc_exportPreset.sqf, and every built-in/user preset - `count >= 5`):
 *    `[id, name, author, description, injuries, tags, katExtras?]`. `name` must be non-blank.
 *  - Bare injuries export (fnc_exportPatientState.sqf's own format - `count` 1 or 2, on request:
 *    exporting a live patient's state used to wrap it in a full Preset envelope too, which carried
 *    nothing but noise for that specific "export this one patient, paste it into another module"
 *    workflow): `[injuries]` or `[injuries, katExtras]`, no id/name/author/description/tags at
 *    all. Given a synthetic name ("Imported Patient") here purely so the shared return tuple always
 *    has one - irrelevant to the AFCM Patient module's own spawn-time import, which never reads it,
 *    but keeps a sensible label if this ends up saved into the Preset Library via
 *    fnc_importPreset.sqf.
 *
 * katExtras (`[fractures <ARRAY[6]>, pneumothoraxType, airwayType, cardiacRhythm]`) is optional in
 * both shapes - a preset/export is still valid with only a name plus EITHER a non-empty injuries
 * array OR a non-default katExtras (not neither), since a patient exported with just a cardiac
 * arrest and no base wound is real and valid on its own.
 *
 * `call compile` on pasted/authored text only ever runs on whichever machine calls this (the
 * importing player's own client for the Preset Library, the server for an Eden module attribute at
 * mission init) - same trust level either already has over their own client/mission file, not a
 * new attack surface. Malformed/unrecognized input is rejected ([]) rather than trusted.
 *
 * Arguments:
 * 0: Exported string <STRING>
 *
 * Return Value:
 * [name <STRING>, injuries <ARRAY of [limb, woundType, severity, bleeding, bleedRate?]>,
 *  author <STRING>, description <STRING>, tags <ARRAY of STRING>, katExtras <ARRAY>], or [] if the
 *  string didn't parse into either recognized shape. katExtras is [] when the source had none/an
 *  invalid one. bleedRate (5th tuple element, fnc_buildInjury.sqf) passes through unmodified when
 *  present - the `count _x >= 4` validity check below already tolerates it, `select` doesn't
 *  truncate extra elements, so nothing here needed to change for it.
 *
 * Public: Yes
*/

params ["_exported"];

if (_exported isEqualTo "") exitWith { [] };

// No try/catch in vanilla SQF - genuinely malformed (non-array) input surfaces as an RPT script
// error from `call compile` rather than failing silently, an acceptable outcome for text a human
// pasted/typed in (same class of risk as the debug console).
private _parsed = call compile _exported;

if (typeName _parsed != "ARRAY") exitWith { [] };

private _validLimbs = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"];

// Keeps only well-formed injury entries rather than reject the whole thing over one bad one.
private _fnCleanInjuries = {
    params ["_raw"];
    if (typeName _raw != "ARRAY") exitWith { [] };
    _raw select {
        (_x isEqualType []) &&
        {count _x >= 4} &&
        {(_x select 0) in _validLimbs} &&
        {typeName (_x select 1) == "STRING"} &&
        {typeName (_x select 2) == "SCALAR"} &&
        {typeName (_x select 3) == "BOOL"}
    }
};

private _fnCleanKatExtras = {
    params ["_raw"];
    if (typeName _raw != "ARRAY" || {count _raw != 4}) exitWith { [] };
    _raw params [["_fractures", [], [[]]], ["_pneumoType", 0], ["_airwayType", 0], ["_rhythm", 0]];
    private _fracturesValid = (_fractures isEqualType []) && {count _fractures == 6} && {(_fractures select { typeName _x != "SCALAR" }) isEqualTo []};
    if !(_fracturesValid && {typeName _pneumoType == "SCALAR"} && {typeName _airwayType == "SCALAR"} && {typeName _rhythm == "SCALAR"}) exitWith { [] };
    [_fractures, _pneumoType, _airwayType, _rhythm]
};

private _name = "";
private _author = "";
private _description = "";
private _tags = [];
private _cleanInjuries = [];
private _cleanKatExtras = [];

if (count _parsed >= 5) then {
    _parsed params [["_id", "", [""]], ["_pName", "", [""]], ["_pAuthor", "", [""]], ["_pDescription", "", [""]], ["_pInjuries", [], [[]]], ["_pTags", [], [[]]], ["_pKatExtras", [], [[]]]];
    _name = _pName;
    _author = _pAuthor;
    _description = _pDescription;
    _tags = _pTags;
    _cleanInjuries = [_pInjuries] call _fnCleanInjuries;
    _cleanKatExtras = [_pKatExtras] call _fnCleanKatExtras;
} else {
    if (count _parsed >= 1 && {count _parsed <= 2}) then {
        _name = "Imported Patient";
        _cleanInjuries = [_parsed select 0] call _fnCleanInjuries;
        if (count _parsed == 2) then { _cleanKatExtras = [_parsed select 1] call _fnCleanKatExtras; };
    };
};

if (_name isEqualTo "" || {_cleanInjuries isEqualTo [] && {_cleanKatExtras isEqualTo []}}) exitWith { [] };

[_name, _cleanInjuries, _author, _description, _tags, _cleanKatExtras]
