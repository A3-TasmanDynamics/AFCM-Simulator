/*
 * Author: Tasman Dynamics
 * The central navbar handler for RscDisplayAFCM_SIM_InjuryAuthor - switches which limb the form is
 * currently editing. Commits whatever's on screen for the limb being LEFT
 * (fnc_injuryAuthor_commitActiveLimbForm.sqf) before switching, so nothing typed/selected is lost
 * just from clicking a different navbar button - this is the whole point of the redesign, going
 * down the limb list without losing work each time, unlike the old two-screen flow.
 *
 * Also called once from fnc_injuryAuthor_init.sqf to set the initial active limb ("chest") - in
 * that case there's nothing staged yet to commit, but committing an empty/default form is harmless
 * (WoundType defaults to "None", which just means "nothing to stage for this limb" - see
 * fnc_injuryAuthor_commitActiveLimbForm.sqf).
 *
 * Arguments:
 * 0: LimbId <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_limbId"];

call afcm_sim_ui_fnc_injuryAuthor_commitActiveLimbForm;

missionNamespace setVariable ["AFCM_SIM_UI_activeLimb", _limbId];

call afcm_sim_ui_fnc_injuryAuthor_refreshActiveLimbForm;
call afcm_sim_ui_fnc_injuryAuthor_refreshNavbar;

if !(missionNamespace getVariable ["AFCM_SIM_UI_authorNewPatient", true]) then {
    call afcm_sim_ui_fnc_injuryAuthor_refreshState;
};
