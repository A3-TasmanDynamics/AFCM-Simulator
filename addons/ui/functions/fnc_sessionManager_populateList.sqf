/*
 * Author: Tasman Dynamics
 * Fills the Session Manager's listbox from afcm_sim_spawner_fnc_getSessions, one row per active
 * Spawn Session reading "<label> — N patient(s), spawned Xm ago", tagged with the real session id
 * via `lbSetData` (same pattern as the Preset Library) so later handlers can look the exact
 * session up without re-parsing the display text.
 *
 * Patient counts only alive, non-null units - a session's own bookkeeping array can still list a
 * unit that died or was deleted some other way (bled out, killed, manually removed) since only
 * afcm_sim_spawner_fnc_serverDeleteSession/clearAllPatients actually prune the tracking lists.
 *
 * Deliberately doesn't try to restore whatever was selected before a refresh - after a delete, the
 * previous index could now point at an entirely different session (list order can shift), so
 * always starting deselected (Delete Session disabled until something's actually picked again) is
 * the safe default, same as fnc_presetLibrary_populateList.sqf.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_SessionManager <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_display"];

disableSerialization;

private _list = _display displayCtrl 10;
lbClear _list;

private _sessions = call afcm_sim_spawner_fnc_getSessions;

{
    _x params ["_id", "_label", "_spawnTime", "_units"];
    private _aliveCount = count (_units select { !isNull _x && alive _x });
    private _plural = ["", "s"] select (_aliveCount != 1);
    private _minutesAgo = floor ((time - _spawnTime) / 60);
    private _timeText = if (_minutesAgo < 1) then { "just now" } else { format ["%1m ago", _minutesAgo] };

    private _idx = _list lbAdd format ["%1 — %2 patient%3, spawned %4", _label, _aliveCount, _plural, _timeText];
    _list lbSetData [_idx, _id];
} forEach _sessions;

(_display displayCtrl 11) ctrlEnable false;
