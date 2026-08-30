/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Session Manager's Delete Selected Session button. Looks up the
 * selected row's real session id (`lbData`) and remoteExecs the delete request to the server
 * (afcm_sim_spawner_fnc_serverDeleteSession) - never deletes locally (DESIGN.md §6). Doesn't
 * close the dialog - refreshes the list a short moment later instead, so more than one session can
 * be cleared in one visit without reopening this dialog each time.
 *
 * No confirmation prompt here, unlike Clear All Sessions - selecting a specific session and
 * clicking Delete is already a deliberate, targeted two-step action, and matches how the Preset
 * Library's own per-item Delete already works with no separate confirmation either.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Delete Selected Session button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlDelete"];

private _display = ctrlParent _ctrlDelete;
private _index = lbCurSel (_display displayCtrl 10);
if (_index == -1) exitWith {};

private _sessionId = (_display displayCtrl 10) lbData _index;

diag_log text format ["[AFCM-Simulator][UI] Delete Session clicked - session '%1'.", _sessionId];

[_sessionId] remoteExec ["afcm_sim_spawner_fnc_serverDeleteSession", 2];

// Give the server a moment to process the delete and publicVariable the updated session list back
// before refreshing - same tolerance-for-async-state approach already used elsewhere in this addon
// (e.g. spawnPatient's own 1s delay before adding actions).
[{
    private _sessionDisplay = findDisplay 25609;
    if !(isNull _sessionDisplay) then {
        [_sessionDisplay] call afcm_sim_ui_fnc_sessionManager_populateList;
    };
}, [], 0.5] call CBA_fnc_waitAndExecute;
