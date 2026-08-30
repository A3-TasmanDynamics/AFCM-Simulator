/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the injury editor's Apply button (RscDisplayAFCM_SIM_InjuryEditor).
 * Reads the wound-type/severity combos and bleeding checkbox, resolves them to real Injury field
 * values (DESIGN.md §4.2), and remoteExecs the request to the server — never applies the injury
 * locally (DESIGN.md §6, same "request -> server validates/applies" pattern as the prior working
 * prototype, REFERENCES.md).
 *
 * Also reads the Fracture/Pneumothorax combos and, if either control is actually visible (KAT
 * active, and for Pneumothorax the limb is "chest" — fnc_injuryEditor_init.sqf) and not set to
 * "None", remoteExecs those separately (INJURY_CODES.md §6 — no equivalent in the generic Injury
 * object, so they don't go through afcm_sim_fnc_backend_applyInjury at all). One Apply click
 * commits everything configured on this limb, not just the wound.
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
private _limb = missionNamespace getVariable ["AFCM_SIM_UI_targetLimb", "chest"];

diag_log text format ["[AFCM-Simulator][UI] Apply clicked - target %1, limb '%2', woundType '%3', severity %4, bleeding %5.", _targetUnit, _limb, _woundType, _severity, _bleeding];

if (isNull _targetUnit) then {
    diag_log text "[AFCM-Simulator][UI] Apply aborted - AFCM_SIM_UI_targetUnit is objNull.";
} else {
    [_targetUnit, _limb, _woundType, _severity, _bleeding] remoteExec ["afcm_sim_scenario_fnc_serverApplyInjury", 2];
    ["injury.applied", [_targetUnit, _limb, _woundType, _severity, _bleeding]] call afcm_sim_ui_fnc_publish;

    private _ctrlFracture = _display displayCtrl 18;
    if (ctrlShown _ctrlFracture) then {
        private _fracture = lbCurSel _ctrlFracture;
        if (_fracture > 0) then {
            [_targetUnit, _limb, _fracture] remoteExec ["afcm_sim_scenario_fnc_serverApplyKatFracture", 2];
        };
    };

    private _ctrlPneumo = _display displayCtrl 19;
    if (ctrlShown _ctrlPneumo) then {
        private _pneumo = lbCurSel _ctrlPneumo;
        if (_pneumo > 0) then {
            [_targetUnit, _pneumo] remoteExec ["afcm_sim_scenario_fnc_serverApplyKatPneumothorax", 2];
        };
    };
};

closeDialog 0;
