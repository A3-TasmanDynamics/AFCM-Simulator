/*
 * Author: Tasman Dynamics
 * Registers the shared CBA events that carry medical-application work onto whichever machine the
 * target unit is actually local to, real fix for ACE3's `local _unit` requirement on
 * ace_medical_fnc_addDamageToUnit (REFERENCES.md) - see fnc_medical_applyAceStyleInjuryLocal.sqf's
 * own header for the full explanation.
 *
 * Registered exactly once, here in afcm_sim_main (always loads regardless of which backend is
 * active) rather than in ace_compat/kat_compat's own preInit - registering the same event name
 * twice would fire the handler twice per event (both compat addons requiredAddon this one, and
 * both could be loaded on a server even when only one is the *active* backend).
 *
 * preInit, not postInit - matches fnc_disableSpontaneousWakeup.sqf's own reasoning: this only
 * subscribes to CBA's event system, which doesn't depend on backend registration/selection at all,
 * so there's no reason to wait for postInit. CBA_fnc_addEventHandler itself is safe to call this
 * early (same real API fnc_disableSpontaneousWakeup.sqf already uses at preInit).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

["afcm_sim_applyAceStyleInjuryLocal", afcm_sim_fnc_medical_applyAceStyleInjuryLocal] call CBA_fnc_addEventHandler;
