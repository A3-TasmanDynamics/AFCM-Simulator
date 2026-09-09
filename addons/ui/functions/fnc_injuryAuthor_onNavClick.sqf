/*
 * Author: Tasman Dynamics
 * ButtonClick handler for one of the 6 navbar buttons on RscDisplayAFCM_SIM_InjuryAuthor - the
 * limb id is baked into each button's own `action` string in addons/ui/config.cpp
 * (`["head"] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;`, etc.), so this is a thin wrapper
 * around the real work in fnc_injuryAuthor_setActiveLimb.sqf.
 *
 * Also drops native input focus right after handling the click (ctrlSetFocus controlNull) - a
 * clicked RscButton keeps engine focus indefinitely (until some other control takes it), and a
 * focused AFCM_SIM_RscButtonNav's colorFocused[] (addons/ui/config.cpp) then fights the persistent
 * "selected" color fnc_injuryAuthor_refreshNavbar.sqf sets via ctrlSetBackgroundColor - real,
 * confirmed symptom: the selected button kept flashing/pulsing instead of staying solid, whether or
 * not the mouse was still over it. Dropping focus immediately means colorFocused's replace-instead-
 * of-blend behavior (see AFCM_SIM_RscButtonNav's own comment) practically never triggers, so the
 * runtime background color - the one actually meant to represent "selected" - is what's on screen
 * and stays put.
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

ctrlSetFocus controlNull;
