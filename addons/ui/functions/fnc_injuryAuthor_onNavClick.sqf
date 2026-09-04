/*
 * Author: Tasman Dynamics
 * ButtonClick handler for one of the 6 navbar buttons on RscDisplayAFCM_SIM_InjuryAuthor - the
 * limb id is baked into each button's own `action` string in addons/ui/config.cpp
 * (`["head"] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;`, etc.), so this is a thin wrapper
 * around the real work in fnc_injuryAuthor_setActiveLimb.sqf.
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

[_limbId] call afcm_sim_ui_fnc_injuryAuthor_setActiveLimb;
