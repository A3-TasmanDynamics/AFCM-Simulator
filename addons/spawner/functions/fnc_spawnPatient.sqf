/*
 * Author: Tasman Dynamics
 * Spawns one patient unit at the given position and applies the given injuries to it via the
 * active backend (DESIGN.md §2.5). Server-authoritative (DESIGN.md §6) — clients should route
 * through this on the server, not call it locally.
 *
 * Injuries are applied after a short delay rather than immediately on createUnit — a real timing
 * requirement confirmed against a prior working prototype (REFERENCES.md): applying damage
 * immediately on creation doesn't reliably take before the unit's medical state has initialized.
 *
 * Arguments:
 * 0: Position <ARRAY> - ASL/ATL position to spawn at (jittered slightly)
 * 1: Injuries <ARRAY> - array of Injury <HASHMAP>, see DESIGN.md §4.2 (default [])
 *
 * Return Value:
 * Spawned unit <OBJECT>, or objNull if not run on the server
 *
 * Example:
 * [[0,0,0] getPos [], [1] call afcm_sim_scenario_fnc_randomizeInjuries] call afcm_sim_spawner_fnc_spawnPatient
 *
 * Public: Yes
*/

params ["_pos", ["_injuries", []]];

if !(isServer) exitWith { objNull };

if (isNil "AFCM_SIM_patientGroup") then {
    AFCM_SIM_patientGroup = createGroup [civilian, true];
};
if (isNil "AFCM_SIM_spawnedPatients") then {
    AFCM_SIM_spawnedPatients = [];
};

// Z is always forced to 0 here, regardless of what the caller's _pos carries (module logics report
// getPosASL, which has real sea-level altitude in its Z - reusing that Z as an ATL height was
// spawning patients floating above the terrain rather than on it). setPosATL with Z=0 snaps to
// ground level at that x/y.
private _jitteredPos = [
    (_pos select 0) + (random 4 - 2),
    (_pos select 1) + (random 4 - 2),
    0
];

private _unit = AFCM_SIM_patientGroup createUnit ["C_man_1", _jitteredPos, [], 0, "NONE"];
_unit setPosATL _jitteredPos;
_unit setUnitPos "DOWN";
_unit setCaptive true;
_unit setDir (random 360);
_unit setVariable ["AFCM_SIM_isPatient", true, true];

// A patient is a static casualty prop, not an autonomous actor - disableAI "ALL" stops every native
// AI subsystem (movement, targeting, combat FSM). Kept as general hardening even after finding the
// real cause of patients "healing themselves" (afcm_sim_fnc's disableSpontaneousWakeup, main/
// preInit): ACE's own `ace_medical_statemachine_fnc_handleStateUnconscious` spontaneously wakes
// stable-vitals unconscious units on a timer regardless of AI subsystem state - this doesn't stop
// that, but stops the patient doing anything else on its own in the meantime.
_unit disableAI "ALL";

// Patients always spawn unconscious - confirmed native `setUnconscious` (REFERENCES.md), not
// ACE/KAT-specific, so this holds even with no medical backend registered at all (DESIGN.md §2.5).
_unit setUnconscious true;

// Belt-and-suspenders against "healing itself": two targeted upstream fixes
// (afcm_sim_fnc_disableSpontaneousWakeup, disableAI "ALL" above) were each grounded in real ACE3
// source and still didn't fully hold up in live testing, meaning there's at least one more
// mechanism (possibly KAT's own vitals/statemachine integration, addons/vitals/functions/
// fnc_handleUnitVitals.sqf - it visibly replaces ACE's own vitals handler for non-player units)
// that hasn't been pinned down. Rather than keep guessing at the exact upstream cause, this
// directly re-locks the symptom: every 3s, for as long as this specific unit exists, force
// setUnconscious true again. A patient is meant to stay down until an instructor resets it
// (afcm_sim_fnc_backend_reset) - "spontaneously wakes up on its own" is never the intended
// behaviour for this mod regardless of which system causes it.
[
    {
        params ["_args", "_handle"];
        _args params ["_unit"];
        if (isNull _unit || {!alive _unit}) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        _unit setUnconscious true;
    },
    3,
    [_unit]
] call CBA_fnc_addPerFrameHandler;

AFCM_SIM_spawnedPatients pushBack _unit;
publicVariable "AFCM_SIM_spawnedPatients";

[{
    params ["_unit", "_injuries"];
    if (isNull _unit) exitWith {};

    // addAction is local to whichever machine calls it - every client (present + JIP) needs to run
    // this itself for the "Edit Injuries" scroll action to actually show up for them. Deferred here
    // alongside injury application (not run immediately on createUnit) for the same reason - a
    // freshly created unit's netId isn't guaranteed to have finished replicating to every client
    // yet. Called by name (not a config requiredAddons dependency on afcm_sim_ui) since remoteExec
    // resolves function names at runtime regardless of load-order/dependency declarations, same as
    // the prior working prototype (REFERENCES.md, `remoteExec ["med_casualties", 2]`).
    [_unit] remoteExec ["afcm_sim_ui_fnc_addInjuryEditorAction", 0, true];

    { [_unit, _x] call afcm_sim_fnc_backend_applyInjury; } forEach _injuries;
}, [_unit, _injuries], 1] call CBA_fnc_waitAndExecute;

_unit
