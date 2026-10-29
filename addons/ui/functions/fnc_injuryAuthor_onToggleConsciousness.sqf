/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's consciousness checkbox - edit mode only,
 * hidden entirely in author-new-patient mode (fnc_injuryAuthor_init.sqf), same gating reasoning as
 * Reset Patient. Checkbox-style on request (AFCM_SIM_IA_CHECKBOX_* in fnc_injuryAuthor_refreshState.sqf
 * - "Unconscious [X]"/"Unconscious [ ]", ticked = unconscious) rather than a Wake/Knock Out action
 * button - a real native RscCheckBox wasn't used here since this control is still just an
 * AFCM_SIM_RscButton (config.cpp) reusing the exact same ButtonClick/text-sync wiring the old
 * action-button version already had, just reading/writing the checked state from its own text
 * instead of swapping between two action verbs.
 *
 * Reads the checkbox's OWN current text to decide its current state, rather than tracking a
 * separate bool - the live-status PFH (fnc_injuryAuthor_refreshState.sqf, edit mode, every 0.5s)
 * already keeps this control's text in sync with the unit's real state, so the text itself is
 * always the single source of truth for "what's currently checked."
 *
 * Sets the control's own text optimistically before the server round-trip completes - the next
 * refreshState tick (within 0.5s) will correct it from the real state regardless, but there's no
 * reason to make the checkbox look unresponsive for that whole window.
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

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];

if (isNull _targetUnit) exitWith {
    diag_log text "[AFCM-Simulator][UI] Toggle Consciousness aborted - AFCM_SIM_UI_targetUnit is objNull.";
};

// Currently checked (unconscious) if the box shows "[X]" - click flips it to the opposite state.
private _wasUnconscious = (ctrlText _ctrlToggle) == "Unconscious [X]";
private _unconscious = !_wasUnconscious;

_ctrlToggle ctrlSetText (["Unconscious [ ]", "Unconscious [X]"] select _unconscious);

[_targetUnit, _unconscious] remoteExec ["afcm_sim_scenario_fnc_serverSetConsciousness", 2];
