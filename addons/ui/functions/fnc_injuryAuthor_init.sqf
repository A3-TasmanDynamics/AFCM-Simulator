/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_InjuryAuthor. Populates every combo, wires every button,
 * sets up mode-dependent visibility (edit an existing patient vs. author a brand-new one - see
 * fnc_injuryAuthor_open.sqf), and starts the live status PFH (edit mode only). Deferred one frame
 * via CBA_fnc_execNextFrame, same reasoning as the old fnc_injuryEditor_init.sqf: ensures controls
 * exist before being touched.
 *
 * Author-new-patient mode's own "View Live State" button (idc 54,
 * fnc_injuryAuthor_onViewLiveState.sqf) starts enabled only if AFCM_SIM_UI_lastSpawnedPatient
 * already exists - a patient spawned via a PRIOR open of this same dialog this mission, not just
 * this specific session, since the unit itself outlives the dialog closing.
 *
 * WoundType now has a 4th "None" option at index 0 (Gunshot/Shrapnel/Blast shift to 1-3) - means
 * "no injury on this limb", handled as a UI-only sentinel by
 * fnc_injuryAuthor_commitActiveLimbForm.sqf.
 *
 * Bleeding is a 5-option severity combo now, not a checkbox: None/Light/Medium/Heavy/Severe,
 * mapping to real [bleeding<BOOL>, bleedRate<NUMBER>] pairs - None->[false,0], Light->[true,0.1],
 * Medium->[true,0.2], Heavy->[true,0.35], Severe->[true,0.5]. Grounded against
 * fnc_medical_applyAceStyleInjuryLocal.sqf's own real bleedRate->ACE-wound-size bucketing (0.15/0.3
 * thresholds, only 3 real sizes - small/medium/large - exist in ACE's own addWound): Light lands in
 * "small", Medium in "medium", Heavy and Severe both land in "large" (ACE has no 4th size) - Heavy
 * vs. Severe still differ in the stored bleedRate number itself, which matters to KAT's own
 * continuous internal-bleeding math even where ACE's own wound visual can't distinguish further.
 *
 * Fracture/Pneumothorax/Airway/CardiacState combos are populated in index-order-equals-value order
 * (same convention the old InjuryEditor used) so fnc_injuryAuthor_commitActiveLimbForm.sqf/
 * fnc_injuryAuthor_refreshActiveLimbForm.sqf can read/write them via plain lbCurSel/lbSetCurSel with
 * no separate mapping array.
 *
 * InjuryLevel (Random Damage's own level picker) is deliberately its own 4-option scale - Easy/
 * Medium/Hard/Insane, requested by name - mapped directly to afcm_sim_scenario_fnc_randomizeInjuries'
 * own numeric levels 0-3 (that function's own 5th tier, "F*CKED!"/level 4, isn't exposed by this
 * control - still reachable via the shipped afcm_sim_defaultInjuryLevel Addon Option elsewhere,
 * intentionally left untouched by this addition). Defaults to afcm_sim_defaultInjuryLevel, clamped
 * into this control's own 0-3 range.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_InjuryAuthor <DISPLAY>
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

    private _backend = call afcm_sim_fnc_backend_getActive;
    private _authorNewPatient = missionNamespace getVariable ["AFCM_SIM_UI_authorNewPatient", true];

    private _fnc_populate = {
        params ["_ctrl", "_options", ["_curSel", 0]];
        lbClear _ctrl;
        { _ctrl lbAdd _x; } forEach _options;
        _ctrl lbSetCurSel _curSel;
    };

    [_display displayCtrl 20, ["None", "Gunshot", "Shrapnel", "Blast"], 0] call _fnc_populate;
    [_display displayCtrl 21, ["Light", "Moderate", "Severe", "Critical"], 1] call _fnc_populate;
    [_display displayCtrl 22, ["None", "Light", "Medium", "Heavy", "Severe"], 0] call _fnc_populate;
    [_display displayCtrl 24, ["None", "Simple Fracture", "Compound Fracture", "Comminuted Fracture"], 0] call _fnc_populate;
    [_display displayCtrl 26, ["None", "Simple Pneumothorax", "Hemopneumothorax", "Tension Pneumothorax"], 0] call _fnc_populate;
    [_display displayCtrl 28, ["None", "Obstruction", "Occlusion"], 0] call _fnc_populate;

    private _cardiacOptions = if (_backend == "kat") then {
        ["None", "Asystole", "PEA", "Ventricular Fibrillation (Shockable)", "Ventricular Tachycardia (Shockable)"]
    } else {
        ["None", "Cardiac Arrest"]
    };
    [_display displayCtrl 30, _cardiacOptions, 0] call _fnc_populate;

    private _defaultLevel = (missionNamespace getVariable ["afcm_sim_defaultInjuryLevel", 1]) min 3;
    [_display displayCtrl 49, ["Easy", "Medium", "Hard", "Insane"], _defaultLevel] call _fnc_populate;

    private _ctrlApply = _display displayCtrl 40;
    if (_authorNewPatient) then {
        _ctrlApply ctrlSetText "Apply & Spawn Patient";
        _ctrlApply ctrlEnable ((missionNamespace getVariable ["AFCM_SIM_UI_authorSpawnPos", []]) isNotEqualTo []);
        (_display displayCtrl 50) ctrlShow false;
        { (_display displayCtrl _x) ctrlShow true; } forEach [51, 52, 54];
        (_display displayCtrl 54) ctrlEnable !(isNull (missionNamespace getVariable ["AFCM_SIM_UI_lastSpawnedPatient", objNull]));
        (_display displayCtrl 35) ctrlSetText "No live patient yet - spawn one, or click View Live State if you already have.";
    } else {
        _ctrlApply ctrlSetText "Apply";
        _ctrlApply ctrlEnable (_backend in ["ace", "kat"]);
        (_display displayCtrl 50) ctrlShow true;
        { (_display displayCtrl _x) ctrlShow false; } forEach [51, 52, 54];
    };

    {
        _x params ["_idc", "_fnc"];
        (_display displayCtrl _idc) ctrlAddEventHandler ["ButtonClick", _fnc];
    } forEach [
        [40, afcm_sim_ui_fnc_injuryAuthor_onApply],
        [41, afcm_sim_ui_fnc_injuryAuthor_onResetLimb],
        [42, afcm_sim_ui_fnc_injuryAuthor_onSavePreset],
        [43, afcm_sim_ui_fnc_injuryAuthor_onLoadPreset],
        [44, afcm_sim_ui_fnc_injuryAuthor_onExport],
        [45, afcm_sim_ui_fnc_injuryAuthor_onImport],
        [47, afcm_sim_ui_fnc_injuryAuthor_onClearAll],
        [48, afcm_sim_ui_fnc_injuryAuthor_onRandomDamage],
        [50, afcm_sim_ui_fnc_injuryAuthor_onResetPatient],
        [51, afcm_sim_ui_fnc_injuryAuthor_onChooseLocation],
        [54, afcm_sim_ui_fnc_injuryAuthor_onViewLiveState]
    ];

    if (_authorNewPatient) then {
        call afcm_sim_ui_fnc_injuryAuthor_refreshLocationStatus;
    };
    ["chest"] call afcm_sim_ui_fnc_injuryAuthor_setActiveLimb;

    if !(_authorNewPatient) then {
        // Live status readout, 0.5s interval - removed on close by
        // fnc_injuryAuthor_cleanup.sqf (onUnload). Author-new-patient mode never starts this -
        // there's no live unit to query yet.
        private _pfhHandle = [
            { params ["_args", "_handle"]; [_args, _handle] call afcm_sim_ui_fnc_injuryAuthor_refreshState; },
            0.5,
            [_display]
        ] call CBA_fnc_addPerFrameHandler;
        missionNamespace setVariable ["AFCM_SIM_UI_statePFH", _pfhHandle];
    };

    diag_log text format ["[AFCM-Simulator][UI] Injury author dialog opened - authorNewPatient=%1, backend '%2'.", _authorNewPatient, _backend];
}, [_display]] call CBA_fnc_execNextFrame;
