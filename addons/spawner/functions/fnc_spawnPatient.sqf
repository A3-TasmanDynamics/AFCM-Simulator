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
 * Every spawned patient joins a Session (DESIGN.md § Spawn Sessions) - a named group tracked in
 * `AFCM_SIM_spawnSessions` (separately from the flat `AFCM_SIM_spawnedPatients` list, which still
 * covers every patient regardless of session) so a whole session's patients can be deleted
 * together without touching any other session's - e.g. two medics each working their own MCI. If
 * no `_sessionId` is given, one is generated fresh for just this single unit - single-patient
 * spawns (Zeus "Spawn Patient"/Eden "AFCM Patient") get their own one-patient session
 * automatically, with no caller changes needed; batch spawners (MCI Spawner modules, MASCAL Zone,
 * the MCI Creator) generate one id up front and pass the same one to every patient in the batch.
 *
 * Arguments:
 * 0: Position <ARRAY> - ASL/ATL position to spawn at (jittered slightly)
 * 1: Injuries <ARRAY> - array of Injury <HASHMAP>, see DESIGN.md §4.2 (default [])
 * 2: Casualty Type <NUMBER> - 0=Civilian, 1=Military (BLUFOR), 2=Military (OPFOR),
 *    3=Military (Independent) - purely a clothing/appearance pick (DESIGN.md §5), see
 *    afcm_sim_defaultCasualtyType (default 0)
 * 3: Session Id <STRING> (default "" - generates a fresh one for just this unit)
 * 4: Session Label <STRING> (default "" - falls back to "Spawn Patient" if a fresh id was also
 *    generated; ignored if joining an existing session)
 * 5: katExtras <ARRAY> (default []) - the Preset shape's optional 7th element
 *    (fnc_exportPatientState.sqf - `[fractures <ARRAY[6]>, pneumothoraxType, airwayType,
 *    cardiacRhythm]`), applied via afcm_sim_scenario_fnc_serverApplyKatExtras alongside Injuries -
 *    the Eden AFCM Patient module's Injury Preset Import attribute is the real caller
 *
 * Return Value:
 * Spawned unit <OBJECT>, or objNull if not run on the server
 *
 * Example:
 * [[0,0,0] getPos [], [1] call afcm_sim_scenario_fnc_randomizeInjuries] call afcm_sim_spawner_fnc_spawnPatient
 *
 * Public: Yes
*/

params ["_pos", ["_injuries", []], ["_casualtyType", 0], ["_sessionId", ""], ["_sessionLabel", ""], ["_katExtras", []]];

// Purely cosmetic - all four are real, base-game (no DLC/faction mod) Arma 3 classnames, so this
// works with nothing but vanilla + CBA installed. Whatever's picked, gear is stripped down to bare
// clothing below regardless - a military classname's default rifle/vest/backpack loadout doesn't
// survive spawning here, per the "just clothing" requirement.
private _casualtyClasses = ["C_man_1", "B_Soldier_F", "O_Soldier_F", "I_Soldier_F"];
private _class = _casualtyClasses param [_casualtyType, "C_man_1"];

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

private _unit = AFCM_SIM_patientGroup createUnit [_class, _jitteredPos, [], 0, "NONE"];
// Real, confirmed gap fixed here: nothing downstream of this (session bookkeeping, addAction
// wiring) guarded against createUnit ever failing - objNull would otherwise thread silently into
// the shared, publicVariable'd AFCM_SIM_spawnedPatients/AFCM_SIM_spawnSessions state and get
// remoteExec'd onward to addAction-adding functions.
if (isNull _unit) exitWith {
    diag_log text format ["[AFCM-Simulator] spawnPatient aborted - createUnit failed for class '%1' at %2.", _class, _jitteredPos];
    objNull
};
_unit setPosATL _jitteredPos;
_unit setUnitPos "DOWN";
_unit setCaptive true;
_unit setDir (random 360);
_unit setVariable ["AFCM_SIM_isPatient", true, true];

// Strip down to bare clothing - a patient is a casualty prop, not a combatant, and shouldn't spawn
// carrying a weapon/mags/medical supplies of its own (irrelevant for the civilian class, but
// B_Soldier_F/O_Soldier_F/I_Soldier_F above all spawn with a full rifle+vest+backpack loadout by
// default). Uniform is deliberately left alone - that's the actual "clothing" this is about.
removeAllWeapons _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;

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

// Session bookkeeping (DESIGN.md § Spawn Sessions) - a fresh id/label per call unless the caller
// explicitly asked to join an existing one (batch spawners do this so their whole batch lands in
// one session, not one session per patient).
if (_sessionId isEqualTo "") then {
    _sessionId = call afcm_sim_spawner_fnc_newSessionId;
    if (_sessionLabel isEqualTo "") then { _sessionLabel = "Spawn Patient"; };
};

if (isNil "AFCM_SIM_spawnSessions") then {
    AFCM_SIM_spawnSessions = [];
};

private _sessionIdx = AFCM_SIM_spawnSessions findIf { (_x select 0) == _sessionId };
if (_sessionIdx == -1) then {
    AFCM_SIM_spawnSessions pushBack [_sessionId, _sessionLabel, time, [_unit]];
} else {
    ((AFCM_SIM_spawnSessions select _sessionIdx) select 3) pushBack _unit;
};
publicVariable "AFCM_SIM_spawnSessions";

_unit setVariable ["AFCM_SIM_sessionId", _sessionId, true];

[{
    params ["_unit", "_injuries", "_katExtras"];
    if (isNull _unit) exitWith {};

    // addAction is local to whichever machine calls it - every client (present + JIP) needs to run
    // this itself for the "Edit Injuries" scroll action to actually show up for them. Deferred here
    // alongside injury application (not run immediately on createUnit) for the same reason - a
    // freshly created unit's netId isn't guaranteed to have finished replicating to every client
    // yet. Called by name (not a config requiredAddons dependency on afcm_sim_ui) since remoteExec
    // resolves function names at runtime regardless of load-order/dependency declarations, same as
    // the prior working prototype (REFERENCES.md, `remoteExec ["med_casualties", 2]`).
    [_unit] remoteExec ["afcm_sim_ui_fnc_addInjuryEditorAction", 0, true];
    // "Mark as Treated" - the manual half of the Medical Tent's "Both" treated-detection mode
    // (afcm_sim_scenario_fnc_isPatientTreated), same local-addAction reasoning as the line above.
    [_unit] remoteExec ["afcm_sim_ui_fnc_addTreatedAction", 0, true];
    // "Export Patient State" - lets a controller copy this patient's current AFCM-applied injuries
    // out as a reusable Preset string (fnc_exportPatientState.sqf), same local-addAction reasoning.
    [_unit] remoteExec ["afcm_sim_ui_fnc_addExportStateAction", 0, true];

    { [_unit, _x] call afcm_sim_fnc_backend_applyInjury; } forEach _injuries;
    [_unit, _katExtras] call afcm_sim_scenario_fnc_serverApplyKatExtras;
}, [_unit, _injuries, _katExtras], 1] call CBA_fnc_waitAndExecute;

_unit
