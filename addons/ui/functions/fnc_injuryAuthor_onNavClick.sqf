/*
 * Author: Tasman Dynamics
 * ButtonClick handler for one of the 6 navbar buttons on RscDisplayAFCM_SIM_InjuryAuthor - the
 * limb id is baked into each button's own `action` string in addons/ui/config.cpp
 * (`["head"] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;`, etc.), so this is a thin wrapper
 * around the real work in fnc_injuryAuthor_setActiveLimb.sqf.
 *
 * Also drops native input focus after handling the click, since a clicked RscButton keeps engine
 * focus indefinitely (until some other control takes it), and a focused AFCM_SIM_RscButtonNav's
 * colorFocused[] (addons/ui/config.cpp) then fights the persistent "selected" color
 * fnc_injuryAuthor_refreshNavbar.sqf sets via ctrlSetBackgroundColor - real, confirmed symptom: the
 * selected button kept flashing/pulsing instead of staying solid.
 *
 * The clear itself is deferred one frame (CBA_fnc_execNextFrame, same "let the engine finish what
 * it's doing first" reasoning already used throughout this dialog - see fnc_injuryAuthor_init.sqf's
 * own comment) rather than run inline: a same-frame `ctrlSetFocus controlNull;` did NOT stop the
 * flashing (real, confirmed) - the click sequence (mouse-down, then mouse-up/action) apparently
 * finishes assigning native focus to the button AFTER this action code already runs, so an inline
 * clear was just getting silently overwritten a moment later by the engine's own click handling.
 * Running it next frame instead means our clear is the last word.
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

[{ ctrlSetFocus controlNull; }, []] call CBA_fnc_execNextFrame;
