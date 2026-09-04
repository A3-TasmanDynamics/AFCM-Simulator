/*
 * Author: Tasman Dynamics
 * Builds an export string directly from injuries/katExtras arrays already in hand - the shared tail
 * of fnc_exportPatientState.sqf's own logic, factored out here so a second caller (the injury
 * author dialog's Export button, which exports whatever's currently staged - possibly for a patient
 * that doesn't exist yet, so there's no live unit to read from) can produce the identical string
 * format without duplicating the "which shape do I emit" branch.
 *
 * Deliberately a bare array, not a full Preset envelope (id/name/author/description/tags) the way
 * fnc_exportPreset.sqf's output is - see fnc_exportPatientState.sqf's own header for why. Shape:
 * `str _injuries` when there's no KAT extras/cardiac state to carry (so a base-injuries-only export
 * is exactly the injuries array, nothing wrapping it), or `str [_injuries, _katExtras]` when there
 * is. fnc_parseExportedPreset.sqf tells this apart from the full Preset envelope by element count.
 *
 * Arguments:
 * 0: Injuries <ARRAY of [limb, woundType, severity, bleeding, bleedRate?]>
 * 1: katExtras <ARRAY> (default []) - `[fractures <ARRAY[6]>, pneumothoraxType, airwayType,
 *    cardiacRhythm]`
 *
 * Return Value:
 * Exported string <STRING>
 *
 * Public: Yes
*/

params ["_injuries", ["_katExtras", []]];

private _hasKatExtras = (_katExtras isNotEqualTo []) && {_katExtras isNotEqualTo [[0, 0, 0, 0, 0, 0], 0, 0, 0]};

if (_hasKatExtras) then {
    str [_injuries, _katExtras]
} else {
    str _injuries
}
