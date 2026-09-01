/*
 * Author: Tasman Dynamics
 * KAT-specific airway infliction, called directly rather than through the generic Injury/
 * backend-interface dispatch (INJURY_CODES.md §6 / KAT_COMPAT.md §4) - a head/neck-wide condition
 * with no equivalent in the backend-agnostic Injury object.
 *
 * Real, confirmed mechanism (KAT-Advanced-Medical/KAM, addons/airway/functions/fnc_checkAirway.sqf
 * + fnc_treatmentAdvanced_airwayLocal.sqf, both fetched directly this pass): `kat_airway_obstruction`
 * and `kat_airway_occluded` are two mutually-exclusive Bools with genuinely different real
 * treatment paths, not two severities of the same thing - `fnc_treatmentAdvanced_airwayLocal.sqf`
 * explicitly rejects inserting an airway adjunct (Larynxtubus/i-gel/OPA) while `occluded` is true,
 * returning the item to the medic's inventory unused; `obstruction` is exactly what an airway
 * adjunct clears. Setting either variable directly is sufficient - unlike Pneumothorax, there's no
 * companion "apply the state" call to make afterward (`kat_airway_fnc_handleAirway` is KAT's own
 * *random-chance* infliction roll, not a state-application function, so calling it here would be
 * wrong).
 *
 * Deliberately deterministic, matching afcm_sim_kat_fnc_applyPneumothorax/applyFracture - an
 * instructor picking a type here should get exactly what they picked.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Type <NUMBER> - 0=None (clear), 1=Obstruction, 2=Occlusion
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", ["_type", 0]];

if (isNull _unit) exitWith {};

_unit setVariable ["kat_airway_obstruction", _type == 1, true];
_unit setVariable ["kat_airway_occluded", _type == 2, true];
