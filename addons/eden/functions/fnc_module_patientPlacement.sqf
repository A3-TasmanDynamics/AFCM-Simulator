/*
 * Author: Tasman Dynamics
 * Module function for AFCM_SIM_ModulePatientPlacement (Eden). Spawns a patient at the module's
 * resolved position (see below) on mission start. Injuries are clean/unconscious by default -
 * selected afterward via the "Edit Injuries" scroll action every spawned patient gets
 * (afcm_sim_ui_fnc_addInjuryEditorAction, wired up inside afcm_sim_spawner_fnc_spawnPatient itself)
 * - UNLESS the Injury Preset Import attribute is filled in, in which case the patient spawns
 * pre-configured with those exact injuries AND any KAT extras/cardiac state the exported preset
 * carries (eden/config.cpp - same real "one patient, exact injuries" building block "The Job"
 * export/import loop is meant to feed).
 *
 * Position resolution (eden/config.cpp's AFCM_SIM_UseSyncedPosition/AFCM_SIM_SpawnMarkerName):
 * Spawn at Synced Object ticked and at least one unit synced -> that unit's position. Otherwise, a
 * non-blank Spawn Marker Name that resolves to a real placed marker -> that marker's position.
 * Otherwise (the original, still-default behaviour) -> the module's own placed position.
 *
 * Guards against firing more than once per placed module (`AFCM_SIM_moduleFired`, a variable
 * stashed on `_logic` itself) - vanilla Module_F's function has no guaranteed single-fire
 * behaviour (confirmed independently by ACE3's own Modules Framework docs, which built their own
 * wrapper specifically because "there is no guarantee" here), and re-firing would otherwise spawn
 * a duplicate patient silently.
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

private _casualtyType = _logic getVariable ["AFCM_SIM_casualtyType", afcm_sim_defaultCasualtyType];
// Optional Session Name attribute (DESIGN.md § Spawn Sessions) - blank means
// afcm_sim_spawner_fnc_spawnPatient auto-generates one ("Spawn Patient") as before.
private _sessionLabel = _logic getVariable ["AFCM_SIM_sessionName", ""];

private _useSyncedPosition = _logic getVariable ["AFCM_SIM_useSyncedPosition", false];
private _markerName = _logic getVariable ["AFCM_SIM_spawnMarkerName", ""];

private _pos = getPosASL _logic;
if (_useSyncedPosition && {count _units > 0}) then {
    _pos = getPosASL (_units select 0);
} else {
    if (_markerName != "") then {
        if (markerType _markerName != "") then {
            private _markerPos = getMarkerPos _markerName;
            _pos = [_markerPos select 0, _markerPos select 1, 0];
        } else {
            diag_log text format ["[AFCM-Simulator] AFCM Patient module - Spawn Marker Name '%1' doesn't match a placed marker, falling back to the module's own position.", _markerName];
        };
    };
};

private _importString = _logic getVariable ["AFCM_SIM_injuryPresetImport", ""];
private _injuries = [];
private _katExtras = [];
if (_importString != "") then {
    private _cleaned = [_importString] call afcm_sim_scenario_fnc_parseExportedPreset;
    if (_cleaned isEqualTo []) then {
        diag_log text "[AFCM-Simulator] AFCM Patient module - Injury Preset Import didn't parse, spawning clean instead.";
    } else {
        _injuries = (_cleaned select 1) apply {
            _x params ["_limb", "_woundType", "_severity", "_bleeding"];
            [_limb, _woundType, _severity, _bleeding] call afcm_sim_scenario_fnc_buildInjury
        };
        _katExtras = _cleaned select 5;
    };
};

[_pos, _injuries, _casualtyType, "", _sessionLabel, _katExtras] call afcm_sim_spawner_fnc_spawnPatient;
