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
 * Renders via ctrlSetStructuredText now (StatusText/idc 35 is RscStructuredText, config.cpp) rather
 * than plain ctrlSetText - the old single-color wall of one-field-per-line text regularly overflowed
 * the status box once more than a couple of optional fields (Fracture/SpO2/KAT extras) were present
 * at once, with no visual priority between a "Cardiac Arrest: YES" and a routine Pain reading.
 * Reorganized into three sections (Vitals / active limb / KAT advanced) with bold accent-red
 * headers, related fields paired two-per-line to use the box's real width instead of just stacking
 * vertically, and Cardiac Arrest pulled up to directly under Vitals (most life-critical, so it's
 * never the line that gets clipped if a rare worst-case combination still overflows) while KAT's
 * advanced extras stay last/smallest (least critical, lowest priority if space runs out).
 *
 * Also keeps the ConsciousnessToggle button (idc 59) label synced to the unit's REAL current
 * incapacitatedState every tick, not just this function's own text - fixes the toggle drifting out
 * of sync with reality if the patient wakes/passes out from something other than the button itself
 * (e.g. ACE's own natural recovery, or another controller's action).
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

#define AFCM_SIM_IA_HEX_ACCENT "#c1272d"
#define AFCM_SIM_IA_HEX_GOOD "#8bc34a"

private _header = {
    format ["<t color='%1' bold='1'>%2</t><br/>", AFCM_SIM_IA_HEX_ACCENT, _this]
};

private _text = "No live status available (no medical backend active).";
if (count _state > 0) then {
    private _isUnconscious = (_state getOrDefault ["incapacitatedState", ""]) == "UNCONSCIOUS";
    private _isStable = _state getOrDefault ["stable", false];
    private _inCardiacArrest = _state getOrDefault ["inCardiacArrest", false];

    private _consciousness = _state getOrDefault ["lifeState", "?"];
    private _incap = _state getOrDefault ["incapacitatedState", ""];
    if (_incap != "") then { _consciousness = _consciousness + format [" (%1)", _incap]; };

    // Keeps the consciousness checkbox (idc 59, edit mode only) honest against the unit's REAL
    // current state every tick, not just whatever it last set optimistically.
    (_display displayCtrl 59) ctrlSetText (["Unconscious [ ]", "Unconscious [X]"] select _isUnconscious);

    _text = "VITALS" call _header;

    _text = _text + format [
        "Consciousness: <t color='%1'>%2</t>   Stable: <t color='%3'>%4</t><br/>",
        [AFCM_SIM_IA_HEX_ACCENT, ""] select !_isUnconscious, _consciousness,
        [AFCM_SIM_IA_HEX_ACCENT, AFCM_SIM_IA_HEX_GOOD] select _isStable, ["NO", "YES"] select _isStable
    ];

    if (_inCardiacArrest) then {
        _text = _text + format ["<t color='%1' bold='1'>CARDIAC ARREST</t><br/>", AFCM_SIM_IA_HEX_ACCENT];
    };

    _text = _text + format [
        "Pain: %1   Blood Volume: %2L   SpO2: %3%%<br/>",
        _state getOrDefault ["pain", 0],
        _state getOrDefault ["bloodVolume", 6.0],
        _state getOrDefault ["spO2", 97]
    ];

    _text = _text + (toUpper _limbLine) call _header;

    _text = _text + format [
        "Wounds: %1   Bleeding: <t color='%2'>%3</t><br/>",
        _state getOrDefault ["limbWoundCount", 0],
        [AFCM_SIM_IA_HEX_ACCENT, ""] select !(_state getOrDefault ["limbBleeding", false]),
        _state getOrDefault ["bleedingStatus", "No Bleeding"]
    ];

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
        _text = _text + format ["Fracture: %1<br/>", _fractureName];
    };

    if (_isKat) then {
        _text = _text + format ["<t color='%1' bold='1' size='0.85'>ADVANCED (KAT)</t><br/>", AFCM_SIM_IA_HEX_ACCENT];

        private _pneumoNames = ["None", "Simple", "Hemopneumothorax", "Tension"];
        private _pneumoName = _pneumoNames param [_state getOrDefault ["pneumothoraxType", 0], "None"];

        private _airwayName = "Clear";
        if ("airwayStatus" in _state) then {
            private _airwayNames = ["Clear", "Obstruction", "Occlusion"];
            _airwayName = _airwayNames param [_state get "airwayStatus", "Clear"];
        };

        _text = _text + format [
            "<t size='0.85'>Pneumothorax: %1   Airway: %2</t><br/>", _pneumoName, _airwayName
        ];

        private _bleedRate = _state getOrDefault ["internalBleedingRate", 0];
        if (_bleedRate > 0) then {
            _text = _text + format ["<t size='0.85'>Internal Bleeding: %1L/s</t><br/>", _bleedRate];
        };

        private _rhythm = _state getOrDefault ["cardiacRhythm", 0];
        if (_rhythm > 0) then {
            private _rhythmNames = ["Normal", "Asystole", "PEA", "Ventricular Fibrillation", "Ventricular Tachycardia"];
            private _rhythmName = _rhythmNames param [_rhythm, "Normal"];
            _text = _text + format ["<t size='0.85'>Cardiac Rhythm: %1</t><br/>", _rhythmName];
        };
    };
};

(_display displayCtrl 35) ctrlSetStructuredText (parseText _text);
