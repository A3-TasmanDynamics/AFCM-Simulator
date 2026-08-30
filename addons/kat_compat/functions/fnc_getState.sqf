/*
 * Author: Tasman Dynamics
 * KAT - Advanced Medical backend implementation of the getState interface function. Identical to
 * afcm_sim_ace_compat's (KAT_COMPAT.md §3 - KAT extends ACE3's real wound-tracking state, doesn't
 * replace it, so the same read-only getters apply). Deliberately avoids
 * ace_medical_fnc_getBloodLoss (requires `local _unit`) for the same reason as the ACE backend.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> (default "") - if given, includes wound detail for that limb specifically
 *
 * Return Value:
 * State <HASHMAP> - same shape as afcm_sim_ace_fnc_getState, see that file
 *
 * Public: No
*/

params ["_unit", ["_limb", ""]];

if (isNull _unit) exitWith { createHashMap };

private _bodyPartMap = createHashMapFromArray [
    ["head", "head"],
    ["chest", "body"],
    ["leftArm", "leftarm"],
    ["rightArm", "rightarm"],
    ["leftLeg", "leftleg"],
    ["rightLeg", "rightleg"]
];
private _bodyPart = _bodyPartMap getOrDefault [_limb, ""];

private _wounds = if (_bodyPart isEqualTo "") then { [] } else { [_unit, _bodyPart] call ace_medical_fnc_getOpenWounds };
private _bleeding = (_wounds findIf { (_x select 2) > 0 }) != -1;

private _state = createHashMap;
_state set ["injured", [_unit] call ace_medical_fnc_isInjured];
_state set ["pain", _unit getVariable ["ace_medical_pain", 0]];
_state set ["lifeState", lifeState _unit];
_state set ["incapacitatedState", incapacitatedState _unit];
_state set ["limbWoundCount", count _wounds];
_state set ["limbBleeding", _bleeding];
_state
