/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_InjuryEditor. Sets the limb label, populates the wound-type
 * and severity RscCombo controls, and wires the Apply button. Real command usage (`lbAdd`,
 * `lbSetValue`, `lbSetCurSel`, `cbSetChecked`, `ctrlAddEventHandler`) grounded against a real ACE3
 * dialog init function (addons/markers/functions/fnc_initInsertMarker.sqf) rather than guessed —
 * same reasoning for `disableSerialization`/`CBA_fnc_execNextFrame` below (ensures controls exist
 * before being touched, and the display doesn't fail serialization checks).
 *
 * Backend-aware: queries afcm_sim_fnc_backend_getActive and adapts what's shown -
 *  - "ace" / "kat": normal wound type/severity/bleeding controls, labeled with the real backend
 *    name. KAT additionally gets the Fracture/Pneumothorax controls (INJURY_CODES.md §6 - real KAT
 *    state with no ACE equivalent), hidden for plain ACE.
 *  - "afcm" (not implemented yet - afcm_compat is still a stub): Apply disabled, explains why
 *    rather than offering controls that would silently do nothing.
 *  - "" (no backend registered at all): same - Apply disabled, explains why.
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
    private _backend = call afcm_sim_fnc_backend_getActive;

    private _limbNames = createHashMapFromArray [
        ["head", "Head"], ["neck", "Neck"], ["chest", "Chest"], ["abdomen", "Abdomen"],
        ["pelvis", "Pelvis"], ["leftUpperArm", "Left Upper Arm"], ["leftForearm", "Left Forearm"],
        ["rightUpperArm", "Right Upper Arm"], ["rightForearm", "Right Forearm"],
        ["leftThigh", "Left Thigh"], ["leftShin", "Left Shin"],
        ["rightThigh", "Right Thigh"], ["rightShin", "Right Shin"]
    ];
    private _backendNames = createHashMapFromArray [
        ["ace", "ACE Medical"], ["kat", "KAT Advanced Medical"], ["afcm", "AFCM Physiology"]
    ];

    private _ctrlLimbLabel = _display displayCtrl 10;
    private _ctrlApply = _display displayCtrl 14;
    private _ctrlFractureLabel = _display displayCtrl 20;
    private _ctrlFracture = _display displayCtrl 18;
    private _ctrlPneumoLabel = _display displayCtrl 21;
    private _ctrlPneumo = _display displayCtrl 19;

    // "afcm" isn't implemented in this UI yet (afcm_compat is still a stub, DESIGN.md §2.5) - treat
    // it the same as "no backend" rather than pretending ACE/KAT-shaped controls apply to it.
    private _usable = _backend in ["ace", "kat"];

    if (_usable) then {
        _ctrlLimbLabel ctrlSetText format ["Injury — %1 (%2)", _limbNames getOrDefault [_limb, _limb], _backendNames getOrDefault [_backend, _backend]];
        _ctrlApply ctrlEnable true;
    } else {
        if (_backend == "afcm") then {
            _ctrlLimbLabel ctrlSetText "AFCM Physiology is active, but this UI doesn't support it yet.";
        } else {
            _ctrlLimbLabel ctrlSetText "No medical backend active — install ACE3 or KAT to use this.";
        };
        _ctrlApply ctrlEnable false;
    };

    private _isKat = _backend == "kat";
    { _x ctrlShow _isKat; } forEach [_ctrlFractureLabel, _ctrlFracture, _ctrlPneumoLabel, _ctrlPneumo];

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

    lbClear _ctrlFracture;
    {
        _x params ["_label", "_value"];
        _ctrlFracture lbAdd _label;
        _ctrlFracture lbSetValue [_forEachIndex, _value];
    } forEach [["None", 0], ["Stable", 1], ["Compound", 2], ["Comminuted", 3]];
    _ctrlFracture lbSetCurSel 0;

    lbClear _ctrlPneumo;
    {
        _x params ["_label", "_value"];
        _ctrlPneumo lbAdd _label;
        _ctrlPneumo lbSetValue [_forEachIndex, _value];
    } forEach [["None", 0], ["Simple Pneumothorax", 1], ["Hemopneumothorax", 2], ["Tension Pneumothorax", 3]];
    _ctrlPneumo lbSetCurSel 0;

    _ctrlApply ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_injuryEditor_onApply];
    (_display displayCtrl 15) ctrlAddEventHandler ["ButtonClick", { closeDialog 0; }];
    (_display displayCtrl 17) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_injuryEditor_onReset];

    // Live status readout (fnc_injuryEditor_refreshState.sqf), removed on close by
    // fnc_injuryEditor_cleanup.sqf (onUnload). 0.5s interval - fast enough to read as "live"
    // without polling every frame for a value that mostly doesn't change that often.
    private _pfhHandle = [
        { params ["_args", "_handle"]; [_args, _handle] call afcm_sim_ui_fnc_injuryEditor_refreshState; },
        0.5,
        [_display]
    ] call CBA_fnc_addPerFrameHandler;
    missionNamespace setVariable ["AFCM_SIM_UI_statePFH", _pfhHandle];

    diag_log text format ["[AFCM-Simulator][UI] Injury editor opened for limb '%1', backend '%2'.", _limb, _backend];
}, [_display]] call CBA_fnc_execNextFrame;
