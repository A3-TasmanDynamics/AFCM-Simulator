/*
 * Author: Tasman Dynamics
 * Reads a unit's current KAT extras/cardiac state directly from live state and packages it as a
 * katExtras array (`[fractures <ARRAY[6]>, pneumothoraxType, airwayType, cardiacRhythm]`) - the
 * exact same reads fnc_exportPatientState.sqf used to do inline, factored out here so a second
 * caller (fnc_injuryAuthor_loadFromUnit.sqf - pre-loading the injury author dialog's staging form
 * from an already-spawned patient) can reuse the identical logic instead of a third copy.
 *
 * These are AFCM/KAT's own custom variables, not part of ACE's generic wound system, so unlike base
 * injuries there's no reverse-mapping problem here - a plain live read is reliable.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 *
 * Return Value:
 * katExtras <ARRAY> - `[fractures <ARRAY[6]>, pneumothoraxType, airwayType, cardiacRhythm]`
 *
 * Public: Yes
*/

params ["_unit"];

if (isNull _unit) exitWith { [[0, 0, 0, 0, 0, 0], 0, 0, 0] };

private _fractures = _unit getVariable ["kat_surgery_fractures", [0, 0, 0, 0, 0, 0]];

private _pneumoSeverity = _unit getVariable ["kat_breathing_pneumothorax", 0];
private _hemothorax = _unit getVariable ["kat_breathing_hemopneumothorax", false];
private _tensionPneumothorax = _unit getVariable ["kat_breathing_tensionpneumothorax", false];
private _pneumoType = 0;
if (_tensionPneumothorax) then {
    _pneumoType = 3;
} else {
    if (_hemothorax) then { _pneumoType = 2; } else {
        if (_pneumoSeverity > 0) then { _pneumoType = 1; };
    };
};

private _airwayType = 0;
if (_unit getVariable ["kat_airway_occluded", false]) then {
    _airwayType = 2;
} else {
    if (_unit getVariable ["kat_airway_obstruction", false]) then { _airwayType = 1; };
};

// KAT's own rhythm variable wins when set (real detail); a plain ACE arrest with no KAT rhythm
// still reads as rhythm 1 - "any value > 0 just means in arrest" under ACE, matching
// fnc_serverApplyCardiacState.sqf's own semantics.
private _rhythm = _unit getVariable ["kat_circulation_cardiacArrestType", 0];
if (_rhythm == 0 && {_unit getVariable ["ace_medical_vitals_inCardiacArrest", false]}) then {
    _rhythm = 1;
};

[_fractures, _pneumoType, _airwayType, _rhythm]
