/*
 * Author: Tasman Dynamics
 * onLoad handler for RscDisplayAFCM_SIM_InjuryAuthor. Populates every combo, wires every button,
 * sets up mode-dependent visibility (edit an existing patient vs. author a brand-new one - see
 * fnc_injuryAuthor_open.sqf), and starts the live status PFH (edit mode only). Deferred one frame
 * via CBA_fnc_execNextFrame, same reasoning as the old fnc_injuryEditor_init.sqf: ensures controls
 * exist before being touched.
 *
 * Opens on the first limb that actually has something staged, not a hardcoded "chest" - real,
 * confirmed bug: reopening on an already-configured patient always landed on chest regardless of
 * which limb was actually injured, making an intact, correctly-restored/reloaded injury on any
 * other limb look like it had vanished. See the comment further down where this is computed.
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
 * Bleeding is a 4-option combo now, not a checkbox: None/Small/Medium/Large - deliberately named
 * and scaled to match ACE3's own real `addWound` size enum (0/1/2) directly, rather than an
 * invented finer scale that then had to be bucketed down to ACE's 3 real sizes anyway (the old
 * None/Light/Medium/Heavy/Severe 5-option version had exactly that problem - Heavy and Severe both
 * silently collapsed into the same "large" bucket, which just confused matters). Maps to real
 * [bleeding<BOOL>, bleedRate<NUMBER>] pairs - None->[false,0], Small->[true,0.1],
 * Medium->[true,0.2], Large->[true,0.4] - each non-None rate picked to comfortably clear
 * fnc_medical_applyAceStyleInjuryLocal.sqf's own real bucket thresholds (<0.15 small, 0.15-0.3
 * medium, >=0.3 large), so what you pick here is exactly the ACE wound size that results.
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
    [_display displayCtrl 21, ["None", "Light", "Moderate", "Severe", "Critical"], 0] call _fnc_populate;
    [_display displayCtrl 22, ["None", "Small", "Medium", "Large"], 0] call _fnc_populate;
    // Fracture options are backend-dependent, same pattern as CardiacState below: ACE3 has its own
    // real, native fracture mechanic, but it's a plain fractured/not Bool (REFERENCES.md), not
    // KAT's own 0-3 Simple/Compound/Comminuted severity scale - a separate variable under the hood
    // (ace_medical_fractures vs kat_surgery_fractures), not the same state read two ways.
    private _fractureOptions = if (_backend == "kat") then {
        ["None", "Simple Fracture", "Compound Fracture", "Comminuted Fracture"]
    } else {
        ["None", "Fractured"]
    };
    [_display displayCtrl 24, _fractureOptions, 0] call _fnc_populate;
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

    // Navbar hover, driven entirely by script rather than native colorBackgroundActive/colorFocused
    // (both deliberately transparent on AFCM_SIM_RscButtonNav, addons/ui/config.cpp) - real reason:
    // those two natively can't both (a) show a hover cue on inactive buttons that's visibly
    // different from the bright "active" color, so hovering never looks like a false selection, AND
    // (b) stay perfectly identical to the runtime "active" color specifically when hovering the
    // ALREADY-active button (which also natively holds focus after being clicked), to avoid the
    // original focus/hover toggle-flicker bug - a single static class-level color can't be both
    // "distinct from active" and "identical to active" at once. Scripting it sidesteps the
    // contradiction entirely: MouseEnter only applies the hover tint to a button that ISN'T the
    // active limb (so hovering the active one is always a no-op, no flicker), and MouseExit just
    // re-runs the real 3-state refresh (empty/staged/active) to restore the correct color exactly,
    // idempotent even if it fires right after a click already changed which limb is active.
    {
        _x params ["_idc", "_limbId"];
        private _ctrlNav = _display displayCtrl _idc;
        // Tagged directly on the control (setVariable/getVariable, real Control-type feature) rather
        // than relied on as a closure over this loop's own _limbId - a native ctrlAddEventHandler
        // callback is stored and fired later by the engine's own UI event dispatch, not guaranteed
        // to still see this scope's private variables by then (HEMTT's own linter correctly flagged
        // _limbId as unresolved when this first tried to close over it directly).
        _ctrlNav setVariable ["AFCM_SIM_navLimbId", _limbId];
        _ctrlNav ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrlHover"];
            private _limbId = _ctrlHover getVariable ["AFCM_SIM_navLimbId", ""];
            if (_limbId != (missionNamespace getVariable ["AFCM_SIM_UI_activeLimb", ""])) then {
                _ctrlHover ctrlSetBackgroundColor [0.757, 0.153, 0.176, 0.5];
            };
        }];
        _ctrlNav ctrlAddEventHandler ["MouseExit", {
            call afcm_sim_ui_fnc_injuryAuthor_refreshNavbar;
        }];
    } forEach [
        [10, "head"], [11, "chest"], [12, "leftArm"],
        [13, "rightArm"], [14, "leftLeg"], [15, "rightLeg"]
    ];

    if (_authorNewPatient) then {
        call afcm_sim_ui_fnc_injuryAuthor_refreshLocationStatus;
    };

    // Real, confirmed bug fixed here: this used to unconditionally open on "chest" regardless of
    // which limb actually has anything staged/applied - the staged data itself (restored via a
    // draft or loadFromUnit, both already run in fnc_injuryAuthor_open.sqf by this point) was
    // always intact, but reopening on an unrelated empty limb made it LOOK like an already-applied
    // injury had vanished. Now opens on the first limb (head/chest/arms/legs order) that actually
    // has something staged - a real injury, a fracture, pneumothorax/cardiac state on chest, or
    // airway state on head - same "has anything staged" checks fnc_injuryAuthor_refreshNavbar.sqf
    // already does per-limb, just used here to pick where to land instead of just to color a
    // button. Falls back to "chest" only when nothing at all is staged (a genuinely fresh session).
    private _limbOrder = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"];
    private _stagedInjuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];
    private _stagedKatExtras = missionNamespace getVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
    _stagedKatExtras params [["_fractures", [0, 0, 0, 0, 0, 0]], ["_pneumoType", 0], ["_airwayType", 0], ["_rhythm", 0]];
    private _fractureLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];

    private _fnc_limbHasStaged = {
        params ["_limb"];
        if ((_stagedInjuries findIf { (_x select 0) == _limb }) != -1) exitWith { true };
        if (_limb in _fractureLimbs) then {
            private _limbIndex = _limbOrder find _limb;
            if ((_fractures param [_limbIndex, 0]) > 0) exitWith { true };
        };
        if (_limb == "chest" && {_pneumoType > 0 || {_rhythm > 0}}) exitWith { true };
        if (_limb == "head" && {_airwayType > 0}) exitWith { true };
        false
    };

    private _initialLimbIdx = _limbOrder findIf { [_x] call _fnc_limbHasStaged };
    private _initialLimb = _limbOrder param [_initialLimbIdx, "chest"];
    [_initialLimb] call afcm_sim_ui_fnc_injuryAuthor_setActiveLimb;

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
