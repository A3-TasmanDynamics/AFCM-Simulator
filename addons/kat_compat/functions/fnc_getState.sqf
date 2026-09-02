/*
 * Author: Tasman Dynamics
 * KAT - Advanced Medical backend implementation of the getState interface function. Identical to
 * afcm_sim_ace_compat's (KAT_COMPAT.md §3 - KAT extends ACE3's real wound-tracking state, doesn't
 * replace it, so the same read-only getters apply). Deliberately avoids
 * ace_medical_fnc_getBloodLoss (requires `local _unit`) for the same reason as the ACE backend.
 *
 * Also reports this limb's real KAT fracture state and the unit's real KAT pneumothorax/airway
 * state (INJURY_CODES.md §6) - real, confirmed variables (`kat_surgery_fractures`/
 * `kat_breathing_pneumothorax`/`_hemopneumothorax`/`_tensionpneumothorax`/`kat_airway_obstruction`/
 * `_occluded`, see fnc_applyFracture.sqf/fnc_applyPneumothorax.sqf/fnc_applyAirway.sqf), read
 * directly rather than via any KAT getter function (none confirmed to exist for these).
 *
 * "internalBleedingRate" is `kat_circulation_internalBleeding` (real, confirmed from
 * addons/circulation/functions/fnc_updateInternalBleeding.sqf, consumed by
 * addons/pharma/functions/fnc_getBloodVolumeChange.sqf - that function's own docstring confirms
 * the units, "Blood volume change (liters per second)") - the live rate a Hemopneumothorax
 * actually drains `bloodVolume` (below) at, 0 whenever hemopneumothorax isn't active. "bloodVolume"
 * is the same real `ace_medical_bloodVolume` afcm_sim_ace_fnc_getState reports - KAT extends ACE's
 * blood volume tracking rather than replacing it.
 *
 * "cardiacRhythm" is `kat_circulation_cardiacArrestType` (real, confirmed from
 * addons/circulation/functions/fnc_handleCardiacArrest.sqf/fnc_getCardiacArrestHeartRate.sqf, see
 * fnc_applyCardiacState.sqf) - 0=Normal, 1=Asystole, 2=PEA, 3=Ventricular Fibrillation,
 * 4=Ventricular Tachycardia. "inCardiacArrest" is the same real `ace_medical_vitals_
 * inCardiacArrest` afcm_sim_ace_fnc_getState reports.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> (default "") - if given, includes wound detail for that limb specifically
 *
 * Return Value:
 * State <HASHMAP> - same shape as afcm_sim_ace_fnc_getState, plus "fracture" (given limb),
 *   "pneumothoraxType"/"internalBleedingRate"/"cardiacRhythm" (whole-unit), and "airwayStatus"
 *   (only set when the given limb is "head" - 0=Clear, 1=Obstruction, 2=Occlusion)
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
_state set ["bloodVolume", _unit getVariable ["ace_medical_bloodVolume", 6.0]];
_state set ["internalBleedingRate", _unit getVariable ["kat_circulation_internalBleeding", 0]];
_state set ["inCardiacArrest", _unit getVariable ["ace_medical_vitals_inCardiacArrest", false]];
_state set ["cardiacRhythm", _unit getVariable ["kat_circulation_cardiacArrestType", 0]];

private _limbIndex = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"] find _limb;
if (_limbIndex != -1) then {
    _state set ["fracture", (_unit getVariable ["kat_surgery_fractures", [0, 0, 0, 0, 0, 0]]) select _limbIndex];
};
if (_limb == "head") then {
    private _airwayStatus = 0;
    if (_unit getVariable ["kat_airway_obstruction", false]) then { _airwayStatus = 1; };
    if (_unit getVariable ["kat_airway_occluded", false]) then { _airwayStatus = 2; };
    _state set ["airwayStatus", _airwayStatus];
};

if (_unit getVariable ["kat_breathing_tensionpneumothorax", false]) exitWith {
    _state set ["pneumothoraxType", 3];
    _state
};
if (_unit getVariable ["kat_breathing_hemopneumothorax", false]) exitWith {
    _state set ["pneumothoraxType", 2];
    _state
};
_state set ["pneumothoraxType", parseNumber ((_unit getVariable ["kat_breathing_pneumothorax", 0]) > 0)];
_state
