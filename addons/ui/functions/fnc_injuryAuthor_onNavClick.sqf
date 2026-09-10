/*
 * Author: Tasman Dynamics
 * ButtonClick handler for one of the 6 navbar hit-region buttons (Nav*Hit, idc 60-65,
 * AFCM_SIM_RscButtonNavHit) on RscDisplayAFCM_SIM_InjuryAuthor - the limb id is baked into each
 * button's own `action` string in addons/ui/config.cpp
 * (`["head"] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;`, etc.), so this is a thin wrapper
 * around the real work in fnc_injuryAuthor_setActiveLimb.sqf.
 *
 * No native focus/color cleanup needed here (real, confirmed history: two earlier attempts tried
 * dropping native input focus after the click to stop the "selected" navbar entry from
 * flashing/pulsing or getting stuck - neither worked reliably). The navbar's actual color is no
 * longer carried by this button's own native background at all - see AFCM_SIM_RscTextNavBg's own
 * comment (config.cpp) for the two-layer click/color split that made that unnecessary.
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
