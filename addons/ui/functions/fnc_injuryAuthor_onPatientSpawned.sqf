/*
 * Author: Tasman Dynamics
 * remoteExec callback target (client-targeted, not broadcast) for fnc_spawnPatient.sqf's optional
 * "callback owner" param - the only way a client can learn which real unit its own
 * afcm_sim_spawner_fnc_spawnPatient remoteExec call actually produced, since remoteExec itself is
 * fire-and-forget with no return value. fnc_injuryAuthor_onApply.sqf's author-new-patient branch and
 * fnc_spawnPatientPicker_onSpawn.sqf (Zeus Spawn Patient module) both pass a callback owner
 * (clientOwner, their own) to reach this.
 *
 * Stashes the unit as AFCM_SIM_UI_lastSpawnedPatient (survives dialog close/reopen - a plain
 * missionNamespace var, same reasoning fnc_injuryAuthor_open.sqf already uses for
 * AFCM_SIM_UI_targetUnit).
 *
 * Two real callers now, told apart by whether the Injury Author dialog is still open in
 * author-new-patient mode when this lands:
 *  - fnc_injuryAuthor_onApply.sqf's author-new-patient branch deliberately leaves the dialog open
 *    across the spawn (see its own docstring) - lands here with the dialog still open in that mode,
 *    so this enables its "View Live State" button (idc 54) AND immediately starts the same
 *    live-status PFH that button triggers (afcm_sim_ui_fnc_injuryAuthor_onViewLiveState), matching
 *    edit mode's own auto-start behaviour (fnc_injuryAuthor_init.sqf) instead of requiring a manual
 *    click first - real, confirmed bug fixed previously (status silently looked "not live" until
 *    that click happened).
 *  - fnc_spawnPatientPicker_onSpawn.sqf (Zeus Spawn Patient module) has no Injury Author dialog open
 *    at all by the time this lands - its own picker dialog already closed before the spawn even went
 *    out. Real, confirmed bug fixed here: this callback used to do nothing in that case (it only ever
 *    enabled a button on an already-open dialog), so the module's documented "auto opens edit
 *    injuries window after the faction window" behaviour silently never happened. Falls through to
 *    opening the Injury Author directly on the newly-spawned unit (edit mode - a real spawned unit
 *    given as `_targetUnit` always opens fnc_injuryAuthor_open.sqf in edit mode, never
 *    author-new-patient mode), the same direct open the module's own pre-refactor code used to do
 *    itself.
 *
 * Arguments:
 * 0: Spawned unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit"];

if (isNull _unit) exitWith {};

missionNamespace setVariable ["AFCM_SIM_UI_lastSpawnedPatient", _unit];

disableSerialization;

// 25611 = IDD_AFCM_SIM_INJURYAUTHOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
private _display = findDisplay 25611;

if (!(isNull _display) && {missionNamespace getVariable ["AFCM_SIM_UI_authorNewPatient", false]}) exitWith {
    // 54 = IDC_AFCM_SIM_IA_VIEWLIVESTATE (addons/ui/config.cpp) - see fnc_injuryAuthor_onPatientSpawned
    // docstring above for why this can't just use the #define directly.
    private _ctrlViewLiveState = _display displayCtrl 54;
    _ctrlViewLiveState ctrlEnable true;
    [_ctrlViewLiveState] call afcm_sim_ui_fnc_injuryAuthor_onViewLiveState;
};

[_unit] call afcm_sim_ui_fnc_injuryAuthor_open;
