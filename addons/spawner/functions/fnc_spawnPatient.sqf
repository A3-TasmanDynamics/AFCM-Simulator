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
// AI subsystem (movement, targeting, combat FSM). Kept as general hardening, though it turned out
// to NOT be what was letting patients "heal themselves" - see below.
_unit disableAI "ALL";

// Patients always spawn unconscious, via the active backend (DESIGN.md §2.5) rather than the raw
// engine `setUnconscious` command. This distinction is the real, now-confirmed root cause of
// patients "healing themselves" (REFERENCES.md): the engine command only changes the
// ragdoll/animation state. ACE/KAT track their own consciousness independently via a
// "ACE_isUnconscious" variable (real macro: `IS_UNCONSCIOUS(unit) = (unit getVariable
// ["ACE_isUnconscious", false])`, addons/medical_engine/script_macros_medical.hpp), which the raw
// engine command never touches. `ace_medical_ai`'s own CBA state machine
// (addons/medical_ai/stateMachine.inc.sqf) ticks over every locally-known unit on its own schedule
// - entirely independent of `disableAI` - and immediately self-treats any unit ACE itself still
// considers conscious, no matter what the engine/ragdoll state looks like. The correct call is
// `ace_medical_fnc_setUnconscious`, wrapped here as a backend op (afcm_sim_ace_fnc_setUnconscious/
// afcm_sim_kat_fnc_setUnconscious) so this stays backend-agnostic. If no backend is active/
// registered yet, this is a no-op (diag_log only) - there's nothing ACE-specific to set.
[_unit] call afcm_sim_fnc_backend_setUnconscious;

// Belt-and-suspenders: keeps re-asserting the correct backend-tracked unconsciousness every 3s for
// as long as this specific unit exists, in case anything (spontaneous wake-up chance, KAT's own
// vitals handling, a future backend) tries to wake it. A patient is meant to stay down until an
// instructor resets it (afcm_sim_fnc_backend_reset) - "spontaneously wakes up on its own" is never
// the intended behaviour for this mod. fnc_setUnconscious.sqf early-exits if already
// ACE-unconscious, so this is a cheap no-op on every tick where nothing actually needs re-locking.
[
    {
        params ["_args", "_handle"];
        _args params ["_unit"];
        if (isNull _unit || {!alive _unit}) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        [_unit] call afcm_sim_fnc_backend_setUnconscious;
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
