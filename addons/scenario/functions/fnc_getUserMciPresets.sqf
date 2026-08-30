/*
 * Author: Tasman Dynamics
 * Returns the calling player's own saved MCI presets - stored in `profileNamespace` under a
 * separate key from single-injury Presets (AFCM_SIM_userMciPresets vs AFCM_SIM_userPresets), same
 * per-player/per-machine persistence reasoning as fnc_getUserPresets.sqf.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * MciPresets <ARRAY of MciPreset> - see fnc_getBuiltinMciPresets.sqf for the shape
 *
 * Public: Yes
*/

profileNamespace getVariable ["AFCM_SIM_userMciPresets", []]
