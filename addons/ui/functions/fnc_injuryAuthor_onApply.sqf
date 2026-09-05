/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's Apply button - commits the active limb's form
 * first (fnc_injuryAuthor_commitActiveLimbForm.sqf), then branches on
 * AFCM_SIM_UI_authorNewPatient:
 *
 *  - Edit mode: remoteExecs the whole staged set to the live AFCM_SIM_UI_targetUnit in one
 *    afcm_sim_scenario_fnc_serverApplyPreset call - never applies locally (DESIGN.md §6). Publishes
 *    "injury.applied" per staged entry (same UI event-bus contract the old InjuryEditor's Apply
 *    already had).
 *  - Author-new-patient mode ("Apply & Spawn Patient"): guarded on AFCM_SIM_UI_authorSpawnPos
 *    actually being set (Apply stays disabled until then, fnc_injuryAuthor_refreshLocationStatus.sqf
 *    - defensive, matches the same guard MCI Creator's own Spawn button has). Builds real Injury
 *    HashMaps from the staged tuples via afcm_sim_scenario_fnc_buildInjury (same pattern
 *    addons/eden/functions/fnc_module_patientPlacement.sqf already uses for its own Injury Preset
 *    Import attribute), then remoteExecs afcm_sim_spawner_fnc_spawnPatient directly. Casualty type
 *    is hardcoded to 0 (civilian) - no picker for it in this dialog. If afcm_sim_rememberLastInjuries
 *    is on, persists the staged set to profileNamespace (AFCM_SIM_lastUsedInjuries/
 *    lastUsedKatExtras) so the next author-new-patient open auto-restores it
 *    (fnc_injuryAuthor_open.sqf).
 *
 * Deliberately does NOT closeDialog afterward, either branch - real feedback: applying/spawning was
 * being treated as a one-shot action that always kicked you back out, so configuring several
 * patients (or tweaking one limb at a time on the same patient) meant reopening the whole dialog
 * every single time. The staged set is left exactly as it was just applied, so hitting Apply again
 * re-applies/spawns-another with no extra setup; fnc_injuryAuthor_cleanup.sqf now snapshots whatever
 * is staged whenever the dialog actually IS closed (Close button/Escape), so nothing is lost by
 * leaving Apply as a non-closing action.
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

call afcm_sim_ui_fnc_injuryAuthor_commitActiveLimbForm;

private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];
private _katExtras = missionNamespace getVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];

if (missionNamespace getVariable ["AFCM_SIM_UI_authorNewPatient", true]) then {
    private _pos = missionNamespace getVariable ["AFCM_SIM_UI_authorSpawnPos", []];
    if (_pos isEqualTo []) exitWith {
        diag_log text "[AFCM-Simulator][UI] Apply & Spawn Patient aborted - no spawn location chosen.";
    };

    private _builtInjuries = _injuries apply {
        _x params ["_limb", "_woundType", "_severity", "_bleeding", ["_bleedRate", -1]];
        [_limb, _woundType, _severity, _bleeding, _bleedRate] call afcm_sim_scenario_fnc_buildInjury
    };

    [_pos, _builtInjuries, 0, "", "", _katExtras] remoteExec ["afcm_sim_spawner_fnc_spawnPatient", 2];

    if (afcm_sim_rememberLastInjuries) then {
        profileNamespace setVariable ["AFCM_SIM_lastUsedInjuries", _injuries];
        profileNamespace setVariable ["AFCM_SIM_lastUsedKatExtras", _katExtras];
        saveProfileNamespace;
    };

    ["Injury Author", "Patient spawned."] call afcm_sim_ui_fnc_showToast;
} else {
    private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
    if (isNull _targetUnit) exitWith {
        diag_log text "[AFCM-Simulator][UI] Apply aborted - AFCM_SIM_UI_targetUnit is objNull.";
    };

    [_targetUnit, _injuries, _katExtras] remoteExec ["afcm_sim_scenario_fnc_serverApplyPreset", 2];
    {
        _x params ["_limb", "_woundType", "_severity", "_bleeding"];
        ["injury.applied", [_targetUnit, _limb, _woundType, _severity, _bleeding]] call afcm_sim_ui_fnc_publish;
    } forEach _injuries;

    ["Injury Author", "Injuries applied."] call afcm_sim_ui_fnc_showToast;
};
