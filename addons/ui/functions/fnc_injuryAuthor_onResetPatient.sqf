/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's Reset Patient button - edit mode only, hidden
 * entirely in author-new-patient mode (fnc_injuryAuthor_init.sqf). Wipes everything done to the
 * live AFCM_SIM_UI_targetUnit so far (afcm_sim_scenario_fnc_serverReset - fullHeal + re-lock
 * unconscious + clears AFCM_SIM_appliedInjuries, DESIGN.md §6), then reloads the staging form from
 * that now-clean unit after a short delay so it doesn't keep showing stale staged wounds -
 * fnc_serverReset.sqf's own AFCM_SIM_appliedInjuries clear needs a beat to actually land before
 * reading it back, same reasoning fnc_spawnPatient.sqf's own injury-application delay already
 * documents.
 *
 * Doesn't close the dialog afterward - an instructor may want to immediately keep configuring the
 * now-clean patient, same reasoning the old LimbSelect's Reset Patient had.
 *
 * Also wipes the staged form immediately (same lines the now-removed-from-edit-mode Clear All
 * button used to run, fnc_injuryAuthor_onClearAll.sqf) - on request, so this one button reliably
 * clears everything including staged-but-never-applied Random Damage additions right away, rather
 * than relying solely on the delayed loadFromUnit reload below to indirectly overwrite them once
 * the server-side reset lands.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Reset Patient button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlReset"];

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];

diag_log text format ["[AFCM-Simulator][UI] Injury Author Reset Patient clicked - target %1.", _targetUnit];

if (isNull _targetUnit) exitWith {
    diag_log text "[AFCM-Simulator][UI] Reset Patient aborted - AFCM_SIM_UI_targetUnit is objNull.";
};

missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", []];
missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];

profileNamespace setVariable ["AFCM_SIM_lastUsedInjuries", []];
profileNamespace setVariable ["AFCM_SIM_lastUsedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
saveProfileNamespace;

[_targetUnit] remoteExec ["afcm_sim_scenario_fnc_serverReset", 2];

[{
    params ["_targetUnit"];
    if (isNull _targetUnit) exitWith {};
    // Deliberately refreshActiveLimbForm, NOT setActiveLimb - setActiveLimb commits whatever's
    // still on screen first, which would immediately re-stage the pre-reset form values into the
    // arrays loadFromUnit just cleared. This just repaints the form from the now-clean state.
    [_targetUnit] call afcm_sim_ui_fnc_injuryAuthor_loadFromUnit;
    call afcm_sim_ui_fnc_injuryAuthor_refreshActiveLimbForm;
    call afcm_sim_ui_fnc_injuryAuthor_refreshNavbar;
}, [_targetUnit], 1] call CBA_fnc_waitAndExecute;
