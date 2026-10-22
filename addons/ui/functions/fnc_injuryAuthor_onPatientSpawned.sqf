/*
 * Author: Tasman Dynamics
 * remoteExec callback target (client-targeted, not broadcast) for fnc_spawnPatient.sqf's optional
 * "callback owner" param - the only way a client can learn which real unit its own
 * afcm_sim_spawner_fnc_spawnPatient remoteExec call actually produced, since remoteExec itself is
 * fire-and-forget with no return value. fnc_injuryAuthor_onApply.sqf's author-new-patient branch is
 * the only caller that passes a callback owner (clientOwner, its own).
 *
 * Stashes the unit as AFCM_SIM_UI_lastSpawnedPatient (survives dialog close/reopen - a plain
 * missionNamespace var, same reasoning fnc_injuryAuthor_open.sqf already uses for
 * AFCM_SIM_UI_targetUnit) and, if the Injury Author dialog is still open in author-new-patient mode,
 * enables its "View Live State" button (idc 54) AND immediately starts the same live-status PFH
 * that button triggers (afcm_sim_ui_fnc_injuryAuthor_onViewLiveState) - does nothing further itself
 * beyond that, since the dialog might have already been closed by the time this lands (spawnPatient's
 * own 1-tick delay, plus real network latency) - the button being enabled (and the PFH started) on
 * the NEXT open is what fnc_injuryAuthor_init.sqf's own initial-enabled-state check already covers.
 *
 * Real, confirmed bug fixed here: this used to only enable the button, requiring a manual click
 * before the status readout ever started polling - edit mode auto-starts this same PFH on open
 * (fnc_injuryAuthor_init.sqf), so author-new-patient mode silently looked "not live" (stale/blank
 * status, e.g. not reflecting the patient getting shot after spawning) until that click happened.
 * Auto-starting it here matches edit mode's behaviour exactly, reusing
 * fnc_injuryAuthor_onViewLiveState.sqf as-is rather than a parallel implementation (its own
 * `_ctrlViewLiveState` param is unused in its body, so passing the just-enabled control is safe).
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
if (isNull _display) exitWith {};
if !(missionNamespace getVariable ["AFCM_SIM_UI_authorNewPatient", false]) exitWith {};

// 54 = IDC_AFCM_SIM_IA_VIEWLIVESTATE (addons/ui/config.cpp) - see fnc_injuryAuthor_onPatientSpawned
// docstring above for why this can't just use the #define directly.
private _ctrlViewLiveState = _display displayCtrl 54;
_ctrlViewLiveState ctrlEnable true;
[_ctrlViewLiveState] call afcm_sim_ui_fnc_injuryAuthor_onViewLiveState;
