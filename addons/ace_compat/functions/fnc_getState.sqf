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
 *   "bloodVolume": Number - whole-body blood volume in litres, real ACE3 variable
 *     (ace_medical_bloodVolume, default 6.0L - acemod/ACE3, addons/medical_engine/
 *     script_macros_medical.hpp's DEFAULT_BLOOD_VOLUME), plain getVariable read like ace_medical_pain
 *     above, not local-restricted
 *   "inCardiacArrest": Bool - real ACE3 variable (ace_medical_vitals_inCardiacArrest, set via
 *     ace_medical_status_fnc_setCardiacArrestState - see fnc_applyCardiacState.sqf), plain
 *     getVariable read, not local-restricted
 *   "stable": Bool - ace_medical_fnc_isInStableCondition (alive, conscious, zero active wound
 *     bleeding, and "stable vitals" - blood volume/pressure/heart rate/cardiac-output-scaled
 *     blood-loss-rate all within real ACE3 thresholds, REFERENCES.md). Traced its full real call
 *     chain specifically to confirm it does NOT hit the same local-only restriction
 *     ace_medical_fnc_getBloodLoss does, despite transitively computing the same blood-loss value -
 *     it goes through an internal, unguarded ace_medical_status_fnc_getBloodLoss instead - so this
 *     is safe to call from any client here too, same bar as every other getter above
 *   "bleedingStatus": String - "No Bleeding"/"Slow Bleeding"/"Moderate Bleeding"/"Severe Bleeding"/
 *     "Massive Bleeding" - ACE3's own real, whole-unit bleeding-rate classification (medical_gui's
 *     "Show Bleeding Rate" display, REFERENCES.md has the real thresholds/source), computed here
 *     the same way ACE's own fnc_updateInjuryList.sqf does since ACE exposes this only as inline
 *     GUI logic, not a reusable public function - deliberately calls the internal, `Public: No`
 *     ace_medical_status_fnc_getBloodLoss/getCardiacOutput directly rather than reimplementing
 *     ACE's own blood-loss formula by hand (peripheral resistance/bleeding coefficient etc.),
 *     already confirmed neither has a local-only restriction (REFERENCES.md)
 *
 * Public: No
*/

params ["_unit", ["_limb", ""]];

if (isNull _unit) exitWith { createHashMap };

// Same 1:1 LimbId -> ACE body part map as fnc_applyInjury.sqf.
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
_state set ["bloodVolume", _unit getVariable ["ace_medical_bloodVolume", 6.0]];
_state set ["inCardiacArrest", _unit getVariable ["ace_medical_vitals_inCardiacArrest", false]];
_state set ["stable", [_unit] call ace_medical_fnc_isInStableCondition];

private _bleedRate = [_unit] call ace_medical_status_fnc_getBloodLoss;
private _bleedingStatus = "No Bleeding";
if (_bleedRate > 0) then {
    private _cardiacOutput = [_unit] call ace_medical_status_fnc_getCardiacOutput;
    // 0.05 min cardiac output and the 0.1/0.5/1.0 multipliers below are real, confirmed values from
    // ACE3's own fnc_updateInjuryList.sqf (REFERENCES.md) - not guessed.
    private _bleedRateKO = (missionNamespace getVariable ["ace_medical_const_bloodLossKnockOutThreshold", 0.5]) * (_cardiacOutput max 0.05);
    private _tier = 0;
    if (_bleedRate >= _bleedRateKO * 0.1) then { _tier = 1; };
    if (_bleedRate >= _bleedRateKO * 0.5) then { _tier = 2; };
    if (_bleedRate >= _bleedRateKO) then { _tier = 3; };
    _bleedingStatus = ["Slow Bleeding", "Moderate Bleeding", "Severe Bleeding", "Massive Bleeding"] select _tier;
};
_state set ["bleedingStatus", _bleedingStatus];
_state
