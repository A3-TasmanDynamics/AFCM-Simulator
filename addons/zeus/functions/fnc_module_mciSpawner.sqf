/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModuleMciSpawner (Zeus). Spawns a batch of clean, unconscious
 * patients at the module's placement position (DESIGN.md § Map to Spawn Patients / MCI), same
 * jittered-scatter batch spawn as AFCM MASCAL Zone (eden/functions/fnc_module_mascalZone.sqf), but
 * doesn't randomize their injuries by level — instead adds an "Assign MCI Preset" scroll action to
 * the whole batch (afcm_sim_ui_fnc_addMciPresetAction) so the Zeus operator can pick an exact,
 * real Injury Preset (built-in or their own saved one, INJURY_CODES.md §4) and apply it to every
 * patient in the group at once, right after placing them - "select the place on the map, then
 * select a preset" as one continuous flow.
 *
 * Deliberately doesn't try to open the Preset Library dialog directly from this module function -
 * Module_F functions run with `isGlobal = 1` (broadcast to every connected machine, confirmed by
 * every other module in this addon needing its own `isServer` guard for the same reason), so
 * there's no reliable way from here alone to know which single client's curator actually placed
 * this module and should see a dialog pop up. The addAction route sidesteps that entirely - it's
 * the same, already-proven, inherently per-client-local mechanism "Edit Injuries" already uses.
 *
 * Also guards against firing more than once per placed module (`AFCM_SIM_moduleFired`, a variable
 * stashed on `_logic` itself) - vanilla Module_F's function has no guaranteed single-fire
 * behaviour (confirmed independently by ACE3's own Modules Framework docs, which built their own
 * wrapper specifically because "there is no guarantee" here), and re-firing would otherwise spawn
 * duplicate patient batches silently.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed module
 * 1: Units <ARRAY> - synced units, if any
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_logic", "_units", "_activated"];

if !(_activated) exitWith {};
if !(isServer) exitWith {};
if (_logic getVariable ["AFCM_SIM_moduleFired", false]) exitWith {};
_logic setVariable ["AFCM_SIM_moduleFired", true];

private _patientCount = _logic getVariable ["AFCM_SIM_patientCount", 4];
private _casualtyType = _logic getVariable ["AFCM_SIM_casualtyType", afcm_sim_defaultCasualtyType];
private _pos = getPosASL _logic;

// Whole batch shares one Spawn Session (DESIGN.md § Spawn Sessions) - deletable as a group later
// without touching any other session's patients.
private _sessionId = call afcm_sim_spawner_fnc_newSessionId;
private _sessionLabel = format ["MCI Spawner — %1 patients", _patientCount];

private _spawned = [];
for "_i" from 1 to _patientCount do {
    _spawned pushBack ([_pos, [], _casualtyType, _sessionId, _sessionLabel] call afcm_sim_spawner_fnc_spawnPatient);
};

// Same 1s delay afcm_sim_spawner_fnc_spawnPatient itself uses before adding "Edit Injuries" -
// a freshly created unit's netId isn't guaranteed to have finished replicating to every client yet.
[{
    params ["_spawned"];
    [_spawned] remoteExec ["afcm_sim_ui_fnc_addMciPresetAction", 0, true];
}, [_spawned], 1] call CBA_fnc_waitAndExecute;
