/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's Clear All button - wipes the ENTIRE staged
 * set (every limb, plus KAT extras/cardiac state), not just the active limb (Reset Limb). Local
 * only, never touches a live unit - same contract Reset Limb has.
 *
 * Also clears the persisted "remember last-used injuries" state (profileNamespace
 * AFCM_SIM_lastUsedInjuries/lastUsedKatExtras, written by fnc_injuryAuthor_onApply.sqf when
 * afcm_sim_rememberLastInjuries is on) - the "quick clear/reset option" that CBA setting's own
 * tooltip promises, so turning the remembered set off doesn't require digging through profile
 * data by hand.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Clear All button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlClear"];

missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", []];
missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];

profileNamespace setVariable ["AFCM_SIM_lastUsedInjuries", []];
profileNamespace setVariable ["AFCM_SIM_lastUsedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
saveProfileNamespace;

call afcm_sim_ui_fnc_injuryAuthor_refreshActiveLimbForm;
call afcm_sim_ui_fnc_injuryAuthor_refreshNavbar;

["Injury Author", "Cleared all staged injuries."] call afcm_sim_ui_fnc_showToast;
