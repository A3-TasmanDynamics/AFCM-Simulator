/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the injury editor's Apply button (RscDisplayAFCM_SIM_InjuryEditor).
 * Reads the wound-type/severity combos and bleeding checkbox, resolves them to real Injury field
 * values (DESIGN.md §4.2), and remoteExecs one serverApplyInjury request per selected limb
 * (AFCM_SIM_UI_targetLimbs — one or more, fnc_limbSelect_onApplyTrauma.sqf) — never applies
 * locally (DESIGN.md §6, same "request -> server validates/applies" pattern as the prior working
 * prototype, REFERENCES.md). The same wound configuration goes to every selected limb identically.
 *
 * Also reads the Fracture/Pneumothorax/Airway/Cardiac State combos and, if a control is actually
 * visible (KAT active for Fracture/Airway; ACE or KAT active AND "chest" is among the selected
 * limbs for Pneumothorax/Cardiac State — fnc_injuryEditor_init.sqf) and not set to "None",
 * remoteExecs those separately (INJURY_CODES.md §6/§7 — no equivalent in the generic Injury
 * object, so they don't go through afcm_sim_fnc_backend_applyInjury at all). Fracture applies once
 * per selected limb that's an arm or a leg specifically — skipped for head/chest even if they're
 * also part of the selection, same arms/legs-only restriction fnc_injuryEditor_init.sqf uses to
 * decide whether to show the control at all. Pneumothorax, Airway, and Cardiac State each apply
 * once total, not per limb — whole-region/whole-patient conditions, not per-limb ones. One Apply
 * click commits everything configured, for every limb selected, not just one wound.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Apply button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlApply"];

private _display = ctrlParent _ctrlApply;

private _woundTypes = ["gunshot", "shrapnel", "blast"];
private _severities = [0.25, 0.5, 0.75, 1.0];

private _woundTypeLB = _display displayCtrl 11;
private _severityLB = _display displayCtrl 12;
private _bleedingCB = _display displayCtrl 13;

private _woundType = _woundTypes param [lbCurSel _woundTypeLB, "gunshot"];
private _severity = _severities param [lbCurSel _severityLB, 0.5];
private _bleeding = cbChecked _bleedingCB;

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
private _limbs = missionNamespace getVariable ["AFCM_SIM_UI_targetLimbs", ["chest"]];

diag_log text format ["[AFCM-Simulator][UI] Apply clicked - target %1, limb(s) %2, woundType '%3', severity %4, bleeding %5.", _targetUnit, _limbs, _woundType, _severity, _bleeding];

if (isNull _targetUnit) then {
    diag_log text "[AFCM-Simulator][UI] Apply aborted - AFCM_SIM_UI_targetUnit is objNull.";
} else {
    private _ctrlFracture = _display displayCtrl 18;
    private _fracture = if (ctrlShown _ctrlFracture) then { lbCurSel _ctrlFracture } else { -1 };
    private _fractureLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];

    {
        [_targetUnit, _x, _woundType, _severity, _bleeding] remoteExec ["afcm_sim_scenario_fnc_serverApplyInjury", 2];
        ["injury.applied", [_targetUnit, _x, _woundType, _severity, _bleeding]] call afcm_sim_ui_fnc_publish;

        if (_fracture > 0 && {_x in _fractureLimbs}) then {
            [_targetUnit, _x, _fracture] remoteExec ["afcm_sim_scenario_fnc_serverApplyKatFracture", 2];
        };
    } forEach _limbs;

    private _ctrlPneumo = _display displayCtrl 19;
    if (ctrlShown _ctrlPneumo) then {
        private _pneumo = lbCurSel _ctrlPneumo;
        if (_pneumo > 0) then {
            [_targetUnit, _pneumo] remoteExec ["afcm_sim_scenario_fnc_serverApplyKatPneumothorax", 2];
        };
    };

    private _ctrlAirway = _display displayCtrl 23;
    if (ctrlShown _ctrlAirway) then {
        private _airway = lbCurSel _ctrlAirway;
        if (_airway > 0) then {
            [_targetUnit, _airway] remoteExec ["afcm_sim_scenario_fnc_serverApplyKatAirway", 2];
        };
    };

    private _ctrlCardiac = _display displayCtrl 25;
    if (ctrlShown _ctrlCardiac) then {
        private _cardiac = lbCurSel _ctrlCardiac;
        if (_cardiac > 0) then {
            [_targetUnit, _cardiac] remoteExec ["afcm_sim_scenario_fnc_serverApplyCardiacState", 2];
        };
    };
};

closeDialog 0;
