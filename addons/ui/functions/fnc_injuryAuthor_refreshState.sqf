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
        "Consciousness: %1\nPain: %2 | Injured: %3\nBlood Volume: %4L\n%5 — open wounds: %6 | Bleeding: %7",
        _consciousness,
        _state getOrDefault ["pain", 0],
        _state getOrDefault ["injured", false],
        _state getOrDefault ["bloodVolume", 6.0],
        _limbLine,
        _state getOrDefault ["limbWoundCount", 0],
        _state getOrDefault ["limbBleeding", false]
    ];

    if (_state getOrDefault ["inCardiacArrest", false]) then {
        _text = _text + "\nCardiac Arrest: YES";
    };

    if ("fracture" in _state) then {
        private _fractureNames = ["None", "Simple", "Compound", "Comminuted"];
        private _fractureVal = _state get "fracture";
        private _fractureName = _fractureNames param [floor _fractureVal, format ["%1", _fractureVal]];

        private _pneumoNames = ["None", "Simple", "Hemopneumothorax", "Tension"];
        private _pneumoName = _pneumoNames param [_state getOrDefault ["pneumothoraxType", 0], "None"];

        _text = _text + format ["\nFracture (KAT): %1 | Pneumothorax (KAT): %2", _fractureName, _pneumoName];

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
