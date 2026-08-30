/*
 * Author: Tasman Dynamics
 * Serializes one preset to a single-line, shareable text string, for copy-paste export/import
 * (DESIGN.md §4.3 - "user presets need an export/import format... so they're shareable outside the
 * mission file").
 *
 * Deliberately uses the real `str` command on the preset's plain Array (not a HashMap) - a HashMap
 * has no literal SQF syntax, so `str someHashMap` doesn't produce something `call compile` can turn
 * back into a HashMap directly. A plain Array of primitives round-trips through `str`/`call compile`
 * exactly, reliably - which is also why every preset in this addon (built-in and user-saved) is
 * represented as an Array, not the HashMap the original DESIGN.md §4.3 sketch showed.
 *
 * Arguments:
 * 0: Preset <ARRAY> - see fnc_getBuiltinPresets.sqf for the shape
 *
 * Return Value:
 * Exported string <STRING>
 *
 * Public: Yes
*/

params ["_preset"];

str _preset
