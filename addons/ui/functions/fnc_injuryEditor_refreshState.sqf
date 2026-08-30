/*
 * Author: Tasman Dynamics
 * CBA_fnc_addPerFrameHandler callback for RscDisplayAFCM_SIM_InjuryEditor - polls
 * afcm_sim_fnc_backend_getState and updates the Status text control (idc 16) so the dialog shows
 * genuinely live medical state (consciousness, pain, injured, this limb's wound/bleed state) while
 * it's open, not just a one-time snapshot from when it was opened.
 *
 * Self-removes if the dialog is no longer the active display (closed via Apply/Cancel/Escape) -
 * fnc_injuryEditor_cleanup.sqf (onUnload) is the primary removal path, this is a safety net.
 *
 * Real CBA_fnc_addPerFrameHandler callback signature (CBA_A3 source, not guessed):
 * _this = [_args, _handle], where _args is whatever was passed when the handler was added.
 *
 * Arguments (from CBA_fnc_addPerFrameHandler, not called directly):
 * 0: [_display] <ARRAY> - the args passed to CBA_fnc_addPerFrameHandler
 * 1: Handle <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_args", "_handle"];
_args params ["_display"];

// 25602 = IDD_AFCM_SIM_INJURYEDITOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
if (isNull (findDisplay 25602)) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
};

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
private _limb = missionNamespace getVariable ["AFCM_SIM_UI_targetLimb", ""];

if (isNull _targetUnit) exitWith {};

private _state = [_targetUnit, _limb] call afcm_sim_fnc_backend_getState;

private _text = "No live status available (no medical backend active).";
if (count _state > 0) then {
    private _consciousness = _state getOrDefault ["lifeState", "?"];
    private _incap = _state getOrDefault ["incapacitatedState", ""];
    if (_incap != "") then { _consciousness = _consciousness + format [" (%1)", _incap]; };

    _text = format [
        "Consciousness: %1\nPain: %2 | Injured: %3\nThis limb — open wounds: %4 | Bleeding: %5",
        _consciousness,
        _state getOrDefault ["pain", 0],
        _state getOrDefault ["injured", false],
        _state getOrDefault ["limbWoundCount", 0],
        _state getOrDefault ["limbBleeding", false]
    ];

    // KAT-only fields (kat_compat's getState, not ace_compat's - see fnc_getState.sqf) - only
    // present at all when KAT is the active backend, so their presence alone gates showing this.
    if ("fracture" in _state) then {
        private _fractureNames = ["None", "Simple", "Compound", "Comminuted"];
        private _fractureVal = _state get "fracture";
        private _fractureName = _fractureNames param [floor _fractureVal, format ["%1", _fractureVal]];

        private _pneumoNames = ["None", "Simple", "Hemopneumothorax", "Tension"];
        private _pneumoName = _pneumoNames param [_state getOrDefault ["pneumothoraxType", 0], "None"];

        _text = _text + format ["\nFracture (KAT): %1 | Pneumothorax (KAT): %2", _fractureName, _pneumoName];
    };
};

(_display displayCtrl 16) ctrlSetText _text;
