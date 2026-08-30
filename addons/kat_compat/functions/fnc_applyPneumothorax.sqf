/*
 * Author: Tasman Dynamics
 * KAT-specific pneumothorax infliction, called directly rather than through the generic Injury/
 * backend-interface dispatch (INJURY_CODES.md §6 / KAT_COMPAT.md §4) - it's a torso-wide
 * condition, not a per-limb wound, with no equivalent in the backend-agnostic Injury object.
 *
 * Real, confirmed mechanism (KAT-Advanced-Medical/KAM, addons/breathing/functions/
 * fnc_handleBreathing.sqf + fnc_inflictAdvancedPneumothorax.sqf, both fetched directly this pass):
 * `kat_breathing_pneumothorax` is a severity Number on a confirmed 0-4 scale
 * (`_pneumothorax / 4` inside handleBreathing's own breathing-rate calculation; KAT's own real
 * infliction function sets it to exactly `4` for any advanced case), alongside two
 * mutually-exclusive booleans (`kat_breathing_hemopneumothorax`/`kat_breathing_tensionpneumothorax`
 * - KAT's own infliction function explicitly prevents both being true on the same patient at once).
 * Setting the variables alone isn't sufficient - `kat_breathing_fnc_handleBreathing` has to be
 * called afterward to actually apply the state.
 *
 * Deliberately deterministic, unlike KAT's own real infliction function (which rolls a random
 * chance and a random hemo-vs-tension split) - an instructor picking a type here should get
 * exactly what they picked, not a dice roll.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Type <NUMBER> - 0=None, 1=Simple Pneumothorax, 2=Hemopneumothorax, 3=Tension Pneumothorax
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", ["_type", 0]];

if (isNull _unit) exitWith {};

private _severity = [0, 4] select (_type > 0);

_unit setVariable ["kat_breathing_pneumothorax", _severity, true];
_unit setVariable ["kat_breathing_hemopneumothorax", _type == 2, true];
_unit setVariable ["kat_breathing_tensionpneumothorax", _type == 3, true];

[_unit] call kat_breathing_fnc_handleBreathing;
