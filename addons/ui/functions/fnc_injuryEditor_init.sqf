/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_InjuryEditor. Sets the limb label, populates the wound-type
 * and severity RscCombo controls, and wires the Apply button. Real command usage (`lbAdd`,
 * `lbSetValue`, `lbSetCurSel`, `cbSetChecked`, `ctrlAddEventHandler`) grounded against a real ACE3
 * dialog init function (addons/markers/functions/fnc_initInsertMarker.sqf) rather than guessed —
 * same reasoning for `disableSerialization`/`CBA_fnc_execNextFrame` below (ensures controls exist
 * before being touched, and the display doesn't fail serialization checks).
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_InjuryEditor <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display"];

[{
    disableSerialization;
    params ["_display"];

    private _limb = missionNamespace getVariable ["AFCM_SIM_UI_targetLimb", "chest"];

    private _limbNames = createHashMapFromArray [
        ["head", "Head"], ["neck", "Neck"], ["chest", "Chest"], ["abdomen", "Abdomen"],
        ["pelvis", "Pelvis"], ["leftUpperArm", "Left Upper Arm"], ["leftForearm", "Left Forearm"],
        ["rightUpperArm", "Right Upper Arm"], ["rightForearm", "Right Forearm"],
        ["leftThigh", "Left Thigh"], ["leftShin", "Left Shin"],
        ["rightThigh", "Right Thigh"], ["rightShin", "Right Shin"]
    ];

    (_display displayCtrl 10) ctrlSetText format ["Injury — %1", _limbNames getOrDefault [_limb, _limb]];

    private _woundTypeLB = _display displayCtrl 11;
    lbClear _woundTypeLB;
    {
        _x params ["_label", "_value"];
        _woundTypeLB lbAdd _label;
        _woundTypeLB lbSetValue [_forEachIndex, _value];
    } forEach [["Gunshot", 0], ["Shrapnel", 1], ["Blast", 2]];
    _woundTypeLB lbSetCurSel 0;

    private _severityLB = _display displayCtrl 12;
    lbClear _severityLB;
    {
        _x params ["_label", "_value"];
        _severityLB lbAdd _label;
        _severityLB lbSetValue [_forEachIndex, _value];
    } forEach [["Light", 0], ["Moderate", 1], ["Severe", 2], ["Critical", 3]];
    _severityLB lbSetCurSel 1;

    (_display displayCtrl 13) cbSetChecked false;

    (_display displayCtrl 14) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_injuryEditor_onApply];
    (_display displayCtrl 15) ctrlAddEventHandler ["ButtonClick", { closeDialog 0; }];

    // Live status readout (fnc_injuryEditor_refreshState.sqf), removed on close by
    // fnc_injuryEditor_cleanup.sqf (onUnload). 0.5s interval - fast enough to read as "live"
    // without polling every frame for a value that mostly doesn't change that often.
    private _pfhHandle = [
        { params ["_args", "_handle"]; [_args, _handle] call afcm_sim_ui_fnc_injuryEditor_refreshState; },
        0.5,
        [_display]
    ] call CBA_fnc_addPerFrameHandler;
    missionNamespace setVariable ["AFCM_SIM_UI_statePFH", _pfhHandle];

    diag_log text format ["[AFCM-Simulator][UI] Injury editor opened for limb '%1'.", _limb];
}, [_display]] call CBA_fnc_execNextFrame;
