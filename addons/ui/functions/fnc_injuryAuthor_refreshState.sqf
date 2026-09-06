/*
 * Author: Tasman Dynamics
 * Updates the live medical-status readout (RscDisplayAFCM_SIM_InjuryAuthor, idc 35) from
 * afcm_sim_fnc_backend_getState for AFCM_SIM_UI_targetUnit + AFCM_SIM_UI_activeLimb - a straight
 * rekey of the old fnc_injuryEditor_refreshState.sqf, now genuinely accurate for whichever ONE limb
 * is active in the navbar rather than always the first of a possibly-multi-selected array (the old
 * dialog's real limitation, fixed here by construction). Edit-mode only (fnc_injuryAuthor_init.sqf
 * only starts the CBA_fnc_addPerFrameHandler that calls this when AFCM_SIM_UI_authorNewPatient is
 * false) - also called directly (not just from the PFH) by fnc_injuryAuthor_setActiveLimb.sqf so
 * switching limbs updates the readout immediately rather than waiting up to 0.5s for the next tick.
 *
 * Called two ways: from the PFH (real CBA_fnc_addPerFrameHandler callback shape, `_this = [_args,
 * _handle]`) and directly (`call`, `_this` = []) - both handled by defaulting params rather than
 * requiring the PFH's two-argument shape.
 *
 * "Stable" is ACE3's own real ace_medical_fnc_isInStableCondition (both backends' own getState -
 * REFERENCES.md has the full traced call chain/thresholds) - alive, conscious, zero active wound
 * bleeding, and vitals (blood volume/pressure/heart rate/blood-loss rate) all within ACE's own real
 * "stable" bounds. A whole-unit summary, not specific to the active limb.
 *
 * "Bleeding Status" is ACE3's own real No/Slow/Moderate/Severe/Massive Bleeding classification
 * (medical_gui's "Show Bleeding Rate" display - REFERENCES.md has the real thresholds/source),
 * also whole-unit, not to be confused with "Bleeding" below it which is still the active LIMB's
 * own local bool (any of that limb's open wounds actively bleeding).
 *
 * "Fracture" and "SpO2" are both genuinely ACE-native now (REFERENCES.md), not KAT-exclusive -
 * Fracture's own name list is backend-dependent (None/Fractured under ACE vs. KAT's own None/
 * Simple/Compound/Comminuted - two entirely separate variables under the hood, ace_medical_
 * fractures vs. kat_surgery_fractures), detected via "pneumothoraxType" being present in the state
 * HashMap (only kat_compat's own getState ever sets it - "fracture"/"spO2" no longer reliably
 * signal which backend is active, both compat addons report them now). SpO2 is ACE's real
 * continuous "Airway Management" concept (oxygen saturation, altitude/gear/exertion-driven) -
 * genuinely different from KAT's own discrete Obstruction/Occlusion airway states below, not a
 * stand-in for them.
 *
 * Arguments (from CBA_fnc_addPerFrameHandler, or none when called directly):
 * 0: [] <ARRAY> (unused, present only in the PFH-call shape)
 * 1: Handle <NUMBER> (unused, present only in the PFH-call shape)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params [["_args", []], ["_handle", -1]];

disableSerialization;

// 25611 = IDD_AFCM_SIM_INJURYAUTHOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
private _display = findDisplay 25611;
if (isNull _display) exitWith {
    if (_handle != -1) then { [_handle] call CBA_fnc_removePerFrameHandler; };
};

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
if (isNull _targetUnit) exitWith {};

private _limb = missionNamespace getVariable ["AFCM_SIM_UI_activeLimb", "chest"];
private _state = [_targetUnit, _limb] call afcm_sim_fnc_backend_getState;

private _limbNames = createHashMapFromArray [
    ["head", "Head"], ["chest", "Chest"],
    ["leftArm", "Left Arm"], ["rightArm", "Right Arm"],
    ["leftLeg", "Left Leg"], ["rightLeg", "Right Leg"]
];
private _limbLine = _limbNames getOrDefault [_limb, _limb];

private _text = "No live status available (no medical backend active).";
if (count _state > 0) then {
    private _consciousness = _state getOrDefault ["lifeState", "?"];
    private _incap = _state getOrDefault ["incapacitatedState", ""];
    if (_incap != "") then { _consciousness = _consciousness + format [" (%1)", _incap]; };

    _text = format [
        "Consciousness: %1 | Stable: %2\nPain: %3 | Injured: %4\nBlood Volume: %5L\n%6 — open wounds: %7 | Bleeding: %8",
        _consciousness,
        ["NO", "YES"] select (_state getOrDefault ["stable", false]),
        _state getOrDefault ["pain", 0],
        _state getOrDefault ["injured", false],
        _state getOrDefault ["bloodVolume", 6.0],
        _limbLine,
        _state getOrDefault ["limbWoundCount", 0],
        _state getOrDefault ["limbBleeding", false]
    ];

    _text = _text + format ["\nBleeding Status: %1", _state getOrDefault ["bleedingStatus", "No Bleeding"]];

    if (_state getOrDefault ["inCardiacArrest", false]) then {
        _text = _text + "\nCardiac Arrest: YES";
    };

    // "pneumothoraxType" is only ever set by kat_compat's own getState (never ace_compat's) - a
    // reliable "is KAT actually active" signal, unlike "fracture" which both backends now report.
    private _isKat = "pneumothoraxType" in _state;

    private _fractureLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];
    if (_limb in _fractureLimbs) then {
        private _fractureVal = _state getOrDefault ["fracture", 0];
        // ACE's own real fracture state can be -1 (splinted, ace_medical_treatment_fnc_
        // splintLocal) on a LIVE patient even though this dialog's own applyFracture never writes
        // that - this is live state, not just what was authored here.
        private _fractureName = if (_fractureVal < 0) then {
            "Splinted"
        } else {
            (if (_isKat) then { ["None", "Simple", "Compound", "Comminuted"] } else { ["None", "Fractured"] })
                param [floor _fractureVal, format ["%1", _fractureVal]]
        };
        _text = _text + format ["\nFracture: %1", _fractureName];
    };

    _text = _text + format ["\nSpO2: %1%%", _state getOrDefault ["spO2", 97]];

    if (_isKat) then {
        private _pneumoNames = ["None", "Simple", "Hemopneumothorax", "Tension"];
        private _pneumoName = _pneumoNames param [_state getOrDefault ["pneumothoraxType", 0], "None"];
        _text = _text + format ["\nPneumothorax (KAT): %1", _pneumoName];

        if ("airwayStatus" in _state) then {
            private _airwayNames = ["Clear", "Obstruction", "Occlusion"];
            private _airwayName = _airwayNames param [_state get "airwayStatus", "Clear"];
            _text = _text + format ["\nAirway (KAT): %1", _airwayName];
        };

        private _bleedRate = _state getOrDefault ["internalBleedingRate", 0];
        if (_bleedRate > 0) then {
            _text = _text + format ["\nInternal Bleeding (Hemothorax, KAT): %1L/s", _bleedRate];
        };

        private _rhythm = _state getOrDefault ["cardiacRhythm", 0];
        if (_rhythm > 0) then {
            private _rhythmNames = ["Normal", "Asystole", "PEA", "Ventricular Fibrillation", "Ventricular Tachycardia"];
            private _rhythmName = _rhythmNames param [_rhythm, "Normal"];
            _text = _text + format ["\nCardiac Rhythm (KAT): %1", _rhythmName];
        };
    };
};

(_display displayCtrl 35) ctrlSetText _text;
