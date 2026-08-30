/*
 * Author: Tasman Dynamics
 * Button handler for the limb-selection dialog's limb buttons (RscDisplayAFCM_SIM_LimbSelect).
 * Adds or removes the clicked limb from AFCM_SIM_UI_selectedLimbs (a real, standard toggle - real
 * commands `in`/`pushBackUnique`/array subtraction), then refreshes every button's visual state
 * and the Apply Trauma button's text/enabled state (fnc_limbSelect_refreshButtons.sqf) to match.
 *
 * Doesn't navigate anywhere - stays on this dialog so more limbs can be toggled. Continuing to the
 * injury editor happens via the separate Apply Trauma button
 * (fnc_limbSelect_onApplyTrauma.sqf), once at least one limb is selected.
 *
 * Arguments:
 * 0: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1 (head / chest / leftArm / rightArm /
 *    leftLeg / rightLeg)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_limbId"];

if (_limbId in AFCM_SIM_UI_selectedLimbs) then {
    AFCM_SIM_UI_selectedLimbs = AFCM_SIM_UI_selectedLimbs - [_limbId];
} else {
    AFCM_SIM_UI_selectedLimbs pushBackUnique _limbId;
};

diag_log text format ["[AFCM-Simulator][UI] Limb '%1' toggled - selection now %2.", _limbId, AFCM_SIM_UI_selectedLimbs];

// 25601 = IDD_AFCM_SIM_LIMBSELECT (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF, and this `action=` code has no control reference to derive it from (unlike a
// ButtonClick event handler) - keep in sync if that IDD ever changes.
[findDisplay 25601] call afcm_sim_ui_fnc_limbSelect_refreshButtons;
