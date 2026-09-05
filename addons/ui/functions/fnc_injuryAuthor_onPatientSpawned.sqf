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
 * enables its "View Live State" button (idc 54) so it can be used to track this specific patient
 * (fnc_injuryAuthor_onViewLiveState.sqf) - does nothing further itself, since the dialog might have
 * already been closed by the time this lands (spawnPatient's own 1-tick delay, plus real network
 * latency) - the button being enabled on the NEXT open is what fnc_injuryAuthor_init.sqf's own
 * initial-enabled-state check already covers.
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
(_display displayCtrl 54) ctrlEnable true;
