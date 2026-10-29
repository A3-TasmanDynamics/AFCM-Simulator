/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's consciousness checkbox - edit mode only,
 * hidden entirely in author-new-patient mode (fnc_injuryAuthor_init.sqf), same gating reasoning as
 * Reset Patient. Checkbox-style, restyled on request to match this UI's own theme instead of
 * literal "[ ]"/"[X]" bracket text - checked state shown via background color
 * (fnc_injuryAuthor_setConsciousnessCheckbox.sqf) and tracked as a real bool variable on the
 * control itself (`AFCM_SIM_unconsciousChecked`), not parsed back out of its text/color.
 *
 * Purely local/staged - on request ("when apply is selected, it will force the patient awake or
 * unconscious") - just flips its own checked state, same "staged until Apply" contract Blood
 * Volume/SpO2/Pain Level already have (prefilled once at dialog open, not continuously live-synced,
 * only actually sent to the server when fnc_injuryAuthor_onApply.sqf reads it). No longer
 * remoteExecs serverSetConsciousness directly from here - fnc_injuryAuthor_refreshState.sqf's old
 * per-tick sync of this control was removed for the same reason, since fighting a staged-but-not-
 * yet-applied checkbox choice against the unit's still-unchanged real state every 0.5s would just
 * silently revert whatever the player just picked.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Consciousness checkbox <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlToggle"];

private _wasUnconscious = _ctrlToggle getVariable ["AFCM_SIM_unconsciousChecked", false];

[_ctrlToggle, !_wasUnconscious] call afcm_sim_ui_fnc_injuryAuthor_setConsciousnessCheckbox;
