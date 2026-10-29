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
 *    Import attribute), then remoteExecs afcm_sim_spawner_fnc_spawnPatient directly, passing
 *    clientOwner as its trailing "callback owner" so fnc_spawnPatient.sqf remoteExecs the resulting
 *    unit straight back to this specific client (afcm_sim_ui_fnc_injuryAuthor_onPatientSpawned) once
 *    it's ready - what lets the dialog's "View Live State" button track whichever patient this
 *    click actually produced. Casualty type is hardcoded to 0 (civilian) - no picker for it in this
 *    dialog. If afcm_sim_rememberLastInjuries is on, persists the staged set to profileNamespace
 *    (AFCM_SIM_lastUsedInjuries/lastUsedKatExtras) so the next author-new-patient open auto-restores
 *    it (fnc_injuryAuthor_open.sqf).
 *
 * Author-new-patient mode deliberately does NOT closeDialog afterward - real feedback: spawning was
 * being treated as a one-shot action that always kicked you back out, so configuring several
 * patients in a row meant reopening the whole dialog every single time. The staged set is left
 * exactly as it was just applied, so hitting Apply again spawns another with no extra setup;
 * fnc_injuryAuthor_cleanup.sqf snapshots whatever is staged whenever the dialog actually IS closed
 * (Close button/Escape), so nothing is lost by leaving Apply as a non-closing action there.
 *
 * Edit mode DOES closeDialog after a successful Apply now, on request ("when you click apply, the
 * author window should close") - the opposite tradeoff makes sense there: there's exactly one live
 * target unit per edit-mode open, so there's no "configure several in a row" workflow this would
 * interrupt, and leaving it open after committing to a specific patient was the part players found
 * confusing, not helpful.
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

    [_pos, _builtInjuries, 0, "", "", _katExtras, clientOwner] remoteExec ["afcm_sim_spawner_fnc_spawnPatient", 2];

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

    // Settable Blood Volume/SpO2/Pain - edit mode only (config.cpp's own comment on these controls).
    // Clamped to each real ACE3 variable's sane range rather than trusting raw typed input.
    private _display = ctrlParent _ctrlApply;
    private _bloodVolume = 0 max (parseNumber (ctrlText (_display displayCtrl 56))) min 6.5;
    private _spo2 = 0 max (parseNumber (ctrlText (_display displayCtrl 58))) min 100;
    private _pain = 0 max (parseNumber (ctrlText (_display displayCtrl 67))) min 1;
    [_targetUnit, _bloodVolume, _spo2, _pain] remoteExec ["afcm_sim_scenario_fnc_serverSetVitals", 2];

    ["Injury Author", "Injuries applied."] call afcm_sim_ui_fnc_showToast;
    closeDialog 0;
};
