/*
 * Author: Tasman Dynamics
 * Serializes one MCI preset to a single-line, shareable text string - same reasoning as
 * fnc_exportPreset.sqf (`str` on a plain Array round-trips through `call compile` reliably; a
 * HashMap wouldn't).
 *
 * Arguments:
 * 0: MciPreset <ARRAY> - see fnc_getBuiltinMciPresets.sqf for the shape
 *
 * Return Value:
 * Exported string <STRING>
 *
 * Public: Yes
*/

params ["_mciPreset"];

str _mciPreset
