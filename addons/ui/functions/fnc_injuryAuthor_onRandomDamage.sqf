/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's Random Damage button. Rolls a fresh randomized
 * injury set at whatever level the InjuryLevel combo is set to (afcm_sim_scenario_fnc_
 * randomizeInjuries - real Injury HashMaps) and loads it into AFCM_SIM_UI_stagedInjuries, converted
 * to this dialog's own tuple shape - the same "overwrite the whole staged set" pattern
 * Import/Load Preset already use, just generated instead of read from somewhere. Only touches base
 * injuries - randomizeInjuries has no KAT-extras concept at all, so AFCM_SIM_UI_stagedKatExtras is
 * left exactly as it was.
 *
 * InjuryLevel is a 4-option Easy/Medium/Hard/Insane scale (fnc_injuryAuthor_init.sqf), mapped
 * directly (lbCurSel IS the level) to randomizeInjuries' own numeric levels 0-3.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Random Damage button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlRandom"];

disableSerialization;

// 25611 = IDD_AFCM_SIM_INJURYAUTHOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
private _display = findDisplay 25611;
if (isNull _display) exitWith {};

private _level = lbCurSel (_display displayCtrl 49);

private _rolled = [_level] call afcm_sim_scenario_fnc_randomizeInjuries;
private _staged = _rolled apply {
    [_x get "limb", _x get "woundType", _x get "severity", _x get "bleeding", _x get "bleedRate"]
};

missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", _staged];

call afcm_sim_ui_fnc_injuryAuthor_refreshActiveLimbForm;
call afcm_sim_ui_fnc_injuryAuthor_refreshNavbar;

["Injury Author", format ["Rolled %1 random injuries.", count _staged]] call afcm_sim_ui_fnc_showToast;
