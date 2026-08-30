/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Session Manager's Clear All Sessions button. Opens the generic
 * Confirm dialog (fnc_confirmDialog_open.sqf) rather than acting immediately - this is the one
 * action in the whole UI kit with no per-session scoping at all, so it's the highest-blast-radius
 * button in the mod and gets a real Yes/No prompt before anything happens.
 *
 * The stashed Yes code remoteExecs afcm_sim_spawner_fnc_clearAllPatients (never locally, DESIGN.md
 * §6), then refreshes this dialog's list a short moment later, same tolerance-for-async-state
 * pattern as fnc_sessionManager_onDeleteSession.sqf.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Clear All Sessions button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlClearAll"];

[
    "This deletes every spawned patient across every session - not just one. This can't be undone. Continue?",
    {
        diag_log text "[AFCM-Simulator][UI] Clear All Sessions confirmed.";
        [] remoteExec ["afcm_sim_spawner_fnc_clearAllPatients", 2];

        [{
            private _sessionDisplay = findDisplay 25609;
            if !(isNull _sessionDisplay) then {
                [_sessionDisplay] call afcm_sim_ui_fnc_sessionManager_populateList;
            };
        }, [], 0.5] call CBA_fnc_waitAndExecute;
    }
] call afcm_sim_ui_fnc_confirmDialog_open;
