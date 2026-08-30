/*
 * Author: Tasman Dynamics
 * KAT-specific fracture infliction, called directly rather than through the generic Injury/
 * backend-interface dispatch (INJURY_CODES.md §6 / KAT_COMPAT.md §4) - fracture severity has no
 * equivalent in the backend-agnostic Injury object.
 *
 * Real, confirmed mechanism (KAT-Advanced-Medical/KAM, addons/surgery/functions/
 * fnc_fractureSelectLocal.sqf): `kat_surgery_fractures` is a 6-element array, one entry per body
 * part, indexed via `ALL_BODY_PARTS find toLower _bodyPart` - the exact same 6 values
 * AFCM-Simulator's own LimbId uses 1:1 (INJURY_CODES.md §1), so this is a direct index lookup, no
 * folding needed. Severity scale confirmed from that same real source: `_liveFracture >= 3` reads
 * as Comminuted, `>= 2 && < 3` as Compound (still true at the `.1`/`.2`/`.5` treatment-progress
 * substages documented in KAT_COMPAT.md §4), `== 1` as Simple - so a plain integer 1/2/3 here is a
 * real, valid "untreated" starting state, and matches the real terminology ("Simple Fracture", not
 * "Stable").
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1
 * 2: Fracture severity <NUMBER> - 0=None, 1=Simple, 2=Compound, 3=Comminuted
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_limb", ["_severity", 0]];

if (isNull _unit) exitWith {};

private _limbIndex = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"] find _limb;
if (_limbIndex == -1) exitWith {};

private _fractures = _unit getVariable ["kat_surgery_fractures", [0, 0, 0, 0, 0, 0]];
_fractures set [_limbIndex, _severity];
_unit setVariable ["kat_surgery_fractures", _fractures, true];
