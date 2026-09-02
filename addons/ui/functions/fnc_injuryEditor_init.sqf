/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_InjuryEditor. Sets the limb label, populates the wound-type
 * and severity RscCombo controls, and wires the Apply button. Real command usage (`lbAdd`,
 * `lbSetValue`, `lbSetCurSel`, `cbSetChecked`, `ctrlAddEventHandler`) grounded against a real ACE3
 * dialog init function (addons/markers/functions/fnc_initInsertMarker.sqf) rather than guessed —
 * same reasoning for `disableSerialization`/`CBA_fnc_execNextFrame` below (ensures controls exist
 * before being touched, and the display doesn't fail serialization checks).
 *
 * Wound type/severity/bleeding work identically for ACE and KAT (ACE_COMPAT.md §3/KAT_COMPAT.md
 * §3) so they're always shown; Apply is disabled with an explanation if nothing usable is active at
 * all (neither ACE nor KAT loaded, or only AFCM — not supported by this UI yet). Cardiac State
 * (INJURY_CODES.md §7) is also shown for either backend - real cardiac arrest is ACE-native, not
 * KAT-specific - but unlike everything below it, it's not limb-gated at all (a whole-patient vitals
 * state, not tied to any body region); its options differ by backend (ACE: None/Cardiac Arrest;
 * KAT: the full None/Asystole/PEA/VF/VT rhythm enum). Fracture/Pneumothorax/Airway
 * (INJURY_CODES.md §6) are real KAT-only state with no ACE equivalent, so they're shown/hidden
 * here based on the active backend, AND on which limbs are selected: Fracture only when at least
 * one selected limb is an arm or a leg (deliberately excludes head/chest, even though KAT's own
 * data model has a slot for both), Pneumothorax only when "chest" is among the selected limbs (a
 * torso-wide condition, not per-limb), Airway only when "head" is among the selected limbs (a
 * head/neck-wide condition, not per-limb) — each offered as soon as its limb is one of possibly
 * several selected, not only when it's the sole one.
 *
 * AFCM_SIM_UI_targetLimbs is an Array now (fnc_limbSelect_onApplyTrauma.sqf lets the operator
 * toggle more than one limb before continuing here) - the label lists every selected limb by name.
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

    private _limbs = missionNamespace getVariable ["AFCM_SIM_UI_targetLimbs", ["chest"]];
    private _backend = call afcm_sim_fnc_backend_getActive;

    private _limbNames = createHashMapFromArray [
        ["head", "Head"], ["chest", "Chest"],
        ["leftArm", "Left Arm"], ["rightArm", "Right Arm"],
        ["leftLeg", "Left Leg"], ["rightLeg", "Right Leg"]
    ];
    private _limbLabelList = (_limbs apply { _limbNames getOrDefault [_x, _x] }) joinString ", ";

    private _ctrlLimbLabel = _display displayCtrl 10;
    private _ctrlApply = _display displayCtrl 14;

    if (_backend in ["ace", "kat"]) then {
        _ctrlLimbLabel ctrlSetText format ["Injury — %1", _limbLabelList];
        _ctrlLimbLabel ctrlSetTextColor [0.949, 0.937, 0.902, 0.85];
        _ctrlApply ctrlEnable true;
    } else {
        _ctrlLimbLabel ctrlSetText "No medical backend active — install ACE3 or KAT to use this.";
        _ctrlLimbLabel ctrlSetTextColor [0.85, 0.65, 0.2, 1];
        _ctrlApply ctrlEnable false;
    };

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

    private _fractureLB = _display displayCtrl 18;
    lbClear _fractureLB;
    {
        _x params ["_label", "_value"];
        _fractureLB lbAdd _label;
        _fractureLB lbSetValue [_forEachIndex, _value];
    } forEach [["None", 0], ["Simple Fracture", 1], ["Compound Fracture", 2], ["Comminuted Fracture", 3]];
    _fractureLB lbSetCurSel 0;

    private _pneumoLB = _display displayCtrl 19;
    lbClear _pneumoLB;
    {
        _x params ["_label", "_value"];
        _pneumoLB lbAdd _label;
        _pneumoLB lbSetValue [_forEachIndex, _value];
    } forEach [["None", 0], ["Simple Pneumothorax", 1], ["Hemopneumothorax", 2], ["Tension Pneumothorax", 3]];
    _pneumoLB lbSetCurSel 0;

    private _airwayLB = _display displayCtrl 23;
    lbClear _airwayLB;
    {
        _x params ["_label", "_value"];
        _airwayLB lbAdd _label;
        _airwayLB lbSetValue [_forEachIndex, _value];
    } forEach [["None", 0], ["Obstruction", 1], ["Occlusion", 2]];
    _airwayLB lbSetCurSel 0;

    // Shared, unconditional (ACE + KAT), not limb-gated - see ui/config.cpp's own comment. Options
    // depend on backend: ACE has no rhythm concept (afcm_sim_ace_fnc_applyCardiacState only takes
    // a bool), so it only offers None/Cardiac Arrest; KAT offers the full real 0-4 rhythm enum
    // (afcm_sim_kat_fnc_applyCardiacState, INJURY_CODES.md §7).
    private _cardiacLB = _display displayCtrl 25;
    lbClear _cardiacLB;
    private _cardiacOptions = if (_backend == "kat") then {
        [["None", 0], ["Asystole", 1], ["PEA", 2], ["Ventricular Fibrillation (Shockable)", 3], ["Ventricular Tachycardia (Shockable)", 4]]
    } else {
        [["None", 0], ["Cardiac Arrest", 1]]
    };
    {
        _x params ["_label", "_value"];
        _cardiacLB lbAdd _label;
        _cardiacLB lbSetValue [_forEachIndex, _value];
    } forEach _cardiacOptions;
    _cardiacLB lbSetCurSel 0;

    // Fracture: arms/legs only, KAT only - deliberately excludes head/chest even though KAT's own
    // kat_surgery_fractures array has a slot for both (INJURY_CODES.md §4/§6); this UI narrows it
    // to the real limb-fracture/tourniquet-and-splint training case on purpose. Pneumothorax:
    // chest only, KAT only (torso-wide condition - see fnc_applyPneumothorax.sqf/ui/config.cpp
    // comments). Airway: head only, KAT only (head/neck-wide condition - see
    // fnc_applyAirway.sqf). Cardiac State: not limb-gated, shown for ACE or KAT alike. Hidden rows
    // just leave blank space in the panel (Arma dialogs are absolute-positioned, not flow-layout)
    // rather than reflowing it.
    private _fractureLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];
    private _showFracture = (_backend == "kat") && {(_limbs findIf { _x in _fractureLimbs }) != -1};
    private _showPneumo = (_backend == "kat") && {"chest" in _limbs};
    private _showAirway = (_backend == "kat") && {"head" in _limbs};
    private _showCardiac = _backend in ["ace", "kat"];
    { (_display displayCtrl _x) ctrlShow _showFracture; } forEach [18, 20];
    { (_display displayCtrl _x) ctrlShow _showPneumo; } forEach [19, 21];
    { (_display displayCtrl _x) ctrlShow _showAirway; } forEach [23, 24];
    { (_display displayCtrl _x) ctrlShow _showCardiac; } forEach [25, 26];

    _ctrlApply ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_injuryEditor_onApply];
    (_display displayCtrl 15) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_injuryEditor_onBack];
    (_display displayCtrl 17) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_injuryEditor_onReset];
    (_display displayCtrl 22) ctrlAddEventHandler ["ButtonClick", afcm_sim_ui_fnc_injuryEditor_onSavePreset];

    // Live status readout (fnc_injuryEditor_refreshState.sqf), removed on close by
    // fnc_injuryEditor_cleanup.sqf (onUnload). 0.5s interval - fast enough to read as "live"
    // without polling every frame for a value that mostly doesn't change that often.
    private _pfhHandle = [
        { params ["_args", "_handle"]; [_args, _handle] call afcm_sim_ui_fnc_injuryEditor_refreshState; },
        0.5,
        [_display]
    ] call CBA_fnc_addPerFrameHandler;
    missionNamespace setVariable ["AFCM_SIM_UI_statePFH", _pfhHandle];

    diag_log text format ["[AFCM-Simulator][UI] Injury editor opened for limb(s) %1, backend '%2'.", _limbs, _backend];
}, [_display]] call CBA_fnc_execNextFrame;
