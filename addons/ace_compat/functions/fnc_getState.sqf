/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the getState interface function (live medical status for
 * the injury editor UI). Only uses ACE3 getters confirmed NOT to require `local _unit`
 * (REFERENCES.md) - ace_medical_fnc_getBloodLoss does require it and errors otherwise, so it's
 * deliberately not used here; this needs to work when called from any client, not just the server.
 *
 * lifeState/incapacitatedState are vanilla engine commands (confirmed real, docs/arma), not
 * ACE-specific - included since ACE's own unconscious state rides on the same engine lifeState
 * system.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> (default "") - if given, includes wound detail for that limb specifically
 *
 * Return Value:
 * State <HASHMAP>:
 *   "injured": Bool - ace_medical_fnc_isInjured
 *   "pain": Number 0..1 - direct ace_medical_pain variable read (REFERENCES.md)
 *   "lifeState": String - "ALIVE"/"INCAPACITATED"/"DEAD"
 *   "incapacitatedState": String - "UNCONSCIOUS"/"MOVING"/"SHOOTING"/""
 *   "limbWoundCount": Number - open wounds on the given limb (0 if no limb given)
 *   "limbBleeding": Bool - any of that limb's open wounds have a nonzero bleed coefficient
 *
 * Public: No
*/

params ["_unit", ["_limb", ""]];

if (isNull _unit) exitWith { createHashMap };

// Same 13-LimbId -> 6-ACE-body-part fold as fnc_applyInjury.sqf.
private _bodyPartMap = createHashMapFromArray [
    ["head", "head"], ["neck", "body"], ["chest", "body"], ["abdomen", "body"], ["pelvis", "body"],
    ["leftUpperArm", "leftarm"], ["leftForearm", "leftarm"],
    ["rightUpperArm", "rightarm"], ["rightForearm", "rightarm"],
    ["leftThigh", "leftleg"], ["leftShin", "leftleg"],
    ["rightThigh", "rightleg"], ["rightShin", "rightleg"]
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
