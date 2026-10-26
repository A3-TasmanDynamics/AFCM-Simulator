/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's consciousness toggle - edit mode only, hidden
 * entirely in author-new-patient mode (fnc_injuryAuthor_init.sqf), same gating reasoning as Reset
 * Patient. One button, label/action flip based on current state rather than two separate buttons.
 *
 * Reads the button's OWN current text to decide which way to toggle, rather than tracking a
 * separate bool - the live-status PFH (fnc_injuryAuthor_refreshState.sqf, edit mode, every 0.5s)
 * already keeps this control's text in sync with the unit's real state, so the text itself is
 * always the single source of truth for "what will clicking this do right now."
 *
 * Sets the control's own text optimistically before the server round-trip completes - the next
 * refreshState tick (within 0.5s) will correct it from the real state regardless, but there's no
 * reason to make the button look unresponsive for that whole window.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Consciousness toggle button <CONTROL>
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

// Current label names the ACTION, not the state - "Wake Patient" shows while they're unconscious
// (clicking wakes them -> _unconscious false), "Knock Out Patient" shows while conscious (clicking
// knocks them out -> _unconscious true).
private _unconscious = (ctrlText _ctrlToggle) == "Wake Patient";

_ctrlToggle ctrlSetText (["Wake Patient", "Knock Out Patient"] select _unconscious);

[_targetUnit, _unconscious] remoteExec ["afcm_sim_scenario_fnc_serverSetConsciousness", 2];
