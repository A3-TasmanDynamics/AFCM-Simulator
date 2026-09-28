/*
 * Author: Tasman Dynamics
 * Spawns the patient(s) an AFCM_SIM_ModulePatientPlacement logic is configured for - shared between
 * the auto-spawn path (fnc_module_patientPlacement.sqf, fires once at mission start) and the
 * on-demand path (fnc_serverSpawnFromTerminal.sqf, fires every time a synced object's "Spawn Patient"
 * interaction is used) so both honour the SAME Spawn Marker Name precedence instead of two
 * implementations that could drift. Real, confirmed fix: syncing an object used to mean "always spawn
 * at that object's own position, markers ignored entirely" - a placed module with markers configured
 * AND synced to a laptop for on-demand triggering would silently spawn one patient at the laptop
 * instead of one per marker, since the on-demand path never even looked at Spawn Marker Name. Both
 * paths now resolve position the same way: markers first if any are configured and resolve, the
 * caller's own Fallback Position only when Spawn Marker Name is blank or nothing in it resolves - so
 * the synced object becomes a TRIGGER for the configured marker scenario, not a spawn point that
 * overrides it, while still being the sensible fallback for a module that never had markers set at
 * all (or, for the auto-spawn path, its own placed position).
 *
 * Marker names are a comma-separated LIST of exact marker names, not a prefix (own real, confirmed
 * fix - see the comment history in fnc_module_patientPlacement.sqf's git log for the prefix-matching
 * attempt this replaced). Each listed name is `CBA_fnc_trim`'d individually and checked against
 * `markerType`; any name that doesn't resolve to a real placed marker is skipped with a diag_log, not
 * silently dropped along with the whole list.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed AFCM_SIM_ModulePatientPlacement module
 * 1: Fallback Position <ARRAY> - ASL/ATL position to use when Spawn Marker Name is blank or nothing
 *    in it resolves to a real marker (the module's own placed position for the auto-spawn path,
 *    the synced object's current position for the on-demand path)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_logic", "_fallbackPos"];

if !(isServer) exitWith {};
if (isNull _logic) exitWith {};

private _markerNamesRaw = (_logic getVariable ["AFCM_SIM_spawnMarkerName", ""]) call CBA_fnc_trim;
private _requestedNames = if (_markerNamesRaw == "") then { [] } else {
    (_markerNamesRaw splitString ",") apply { _x call CBA_fnc_trim } select { _x != "" }
};
private _matchingMarkers = _requestedNames select { markerType _x != "" };
{
    if !(_x in _matchingMarkers) then {
        diag_log text format ["[AFCM-Simulator] AFCM Patient module - Spawn Marker Name '%1' doesn't match any placed marker, skipping it.", _x];
    };
} forEach _requestedNames;

(_logic call afcm_sim_eden_fnc_resolvePatientAttributes) params ["_injuries", "_casualtyType", "_sessionLabel", "_katExtras"];

if (_matchingMarkers isEqualTo [] || {count _matchingMarkers == 1}) then {
    if (_requestedNames isNotEqualTo [] && {_matchingMarkers isEqualTo []}) then {
        diag_log text format ["[AFCM-Simulator] AFCM Patient module - none of Spawn Marker Name's %1 name(s) matched a placed marker, falling back to the trigger's own position.", count _requestedNames];
    };
    // Exact Position (fnc_spawnPatient.sqf's own 8th arg) is true only when this landed on a real
    // marker - a marker is a deliberately-placed exact spot, unlike the fallback position, which
    // keeps the small random jitter every fallback spawn always had (avoids stacking repeat spawns
    // from the same synced object directly on top of each other/prior patients).
    private _pos = _fallbackPos;
    private _exact = false;
    if (count _matchingMarkers == 1) then {
        private _markerPos = getMarkerPos (_matchingMarkers select 0);
        _pos = [_markerPos select 0, _markerPos select 1, 0];
        _exact = true;
    };
    [_pos, _injuries, _casualtyType, "", _sessionLabel, _katExtras, -1, _exact] call afcm_sim_spawner_fnc_spawnPatient;
} else {
    // One shared session for the whole batch (same "generate one id up front, pass it to every
    // patient" pattern the MCI Spawner modules/MCI Creator already use) - so the whole marker batch
    // can be managed/deleted together in the Session Manager, not one session per marker. A blank
    // Session Name gets a batch-specific default instead of fnc_spawnPatient.sqf's own generic
    // "Spawn Patient" fallback, which only applies when NO session id is passed at all - a real,
    // pre-generated id here would otherwise reach the Session Manager with a blank label. Exact
    // Position (true) - every entry here is a real placed marker, the whole point of this batch mode
    // is precise per-marker placement.
    private _sessionId = call afcm_sim_spawner_fnc_newSessionId;
    if (_sessionLabel == "") then { _sessionLabel = "AFCM Patient (Marker Batch)"; };
    diag_log text format ["[AFCM-Simulator] AFCM Patient module - %1 of Spawn Marker Name's %2 name(s) matched a placed marker, spawning one patient at each.", count _matchingMarkers, count _requestedNames];
    {
        private _markerPos = getMarkerPos _x;
        private _pos = [_markerPos select 0, _markerPos select 1, 0];
        [_pos, _injuries, _casualtyType, _sessionId, _sessionLabel, _katExtras, -1, true] call afcm_sim_spawner_fnc_spawnPatient;
    } forEach _matchingMarkers;
};
