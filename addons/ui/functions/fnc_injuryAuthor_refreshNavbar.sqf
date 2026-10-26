/*
 * Author: Tasman Dynamics
 * Recolors the 6 limb navbar entries (Nav*, idc 10-15, AFCM_SIM_RscTextNavBg - plain RscText, no
 * native button color states at all, see that class's own comment in config.cpp for why) on
 * RscDisplayAFCM_SIM_InjuryAuthor to reflect which one is currently active (AFCM_SIM_UI_activeLimb)
 * and which already have something staged (AFCM_SIM_UI_stagedInjuries, or a relevant nonzero
 * AFCM_SIM_UI_stagedKatExtras slice) - 3 visual states, not the old LimbSelect's 2 (unselected/
 * selected), since this is single-active-limb navigation rather than a multi-toggle. Since the
 * target is a plain RscText, whatever this sets via ctrlSetBackgroundColor is exactly what's shown,
 * always - nothing native can ever override it, unlike when this used to target a real RscButton.
 * Also what the navbar's own MouseExit handler (fnc_injuryAuthor_init.sqf, on the separate Nav*Hit
 * click-region controls) calls to clear a transient hover tint back to the real state.
 *
 * Literal RGBA values, not the AFCM_SIM_COLOR_* #defines (preprocessor-only, unreachable from
 * SQF) - same duplication fnc_limbSelect_refreshButtons.sqf already had. Keep in sync with
 * addons/ui/config.cpp if the brand palette ever changes.
 *
 * Per-limb color logic itself now lives in fnc_injuryAuthor_refreshNavbarLimb.sqf, reused here in a
 * loop over all 6 - factored out so the navbar's own MouseExit handler (fnc_injuryAuthor_init.sqf)
 * can repaint just the ONE limb it's leaving instead of all 6, fixing a real, confirmed bug where
 * repainting every limb on any single MouseExit could wipe out a DIFFERENT limb's just-applied hover
 * tint (the 6 hit-regions are stacked edge-to-edge, so a quick swipe between adjacent limbs fires the
 * new one's MouseEnter before the old one's MouseExit).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

{ [_x] call afcm_sim_ui_fnc_injuryAuthor_refreshNavbarLimb; } forEach
    ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"];
