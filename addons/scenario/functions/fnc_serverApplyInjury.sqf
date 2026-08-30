/*
 * Author: Tasman Dynamics
 * Server-side handler for a manually-authored injury (DESIGN.md §5 "Selectable Injuries") - the
 * "manual" source in the "one application pipeline, three sources: manual, preset, randomized"
 * framing (DESIGN.md §5). Called via remoteExec from afcm_sim_ui's injury editor dialog, never
 * called directly by a client - DESIGN.md §6 requires interventions to be requests validated and
 * applied on the server, the same pattern the prior working prototype used (`remoteExec [...,  2]`,
 * REFERENCES.md).
 *
 * Only scalar primitives cross the remoteExec, not a HashMap - the Injury object (DESIGN.md §4.2)
 * is built here, server-side, from those primitives, then handed to the same
 * afcm_sim_fnc_backend_applyInjury dispatch the randomizer already uses.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1
 * 2: woundType <STRING> - "gunshot"/"shrapnel"/"blast"
 * 3: Severity <NUMBER> - 0.0..1.0
 * 4: Bleeding <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_limb", "_woundType", ["_severity", 0.5], ["_bleeding", false]];

diag_log text format ["[AFCM-Simulator] serverApplyInjury received - unit %1, limb '%2', woundType '%3', severity %4, bleeding %5 (isServer=%6).", _unit, _limb, _woundType, _severity, _bleeding, isServer];

if !(isServer) exitWith {
    diag_log text "[AFCM-Simulator] serverApplyInjury aborted - not running on the server.";
};
if (isNull _unit) exitWith {
    diag_log text "[AFCM-Simulator] serverApplyInjury aborted - unit is objNull on the server (network sync issue?).";
};

// Same 4 limbs as afcm_sim_scenario_fnc_randomizeInjuries - only arms/legs are tourniquetable,
// never head/chest.
private _tourniquetableLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];

private _bleedRate = if (_bleeding) then { 0.1 + random 0.3 } else { 0 };

private _injury = createHashMap;
_injury set ["limb", _limb];
_injury set ["woundType", _woundType];
_injury set ["severity", _severity];
_injury set ["bleeding", _bleeding];
_injury set ["bleedRate", _bleedRate];
_injury set ["tourniquetable", _limb in _tourniquetableLimbs];
_injury set ["variables", createHashMap];

[_unit, _injury] call afcm_sim_fnc_backend_applyInjury;
