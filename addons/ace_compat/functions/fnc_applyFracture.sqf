/*
 * Author: Tasman Dynamics
 * ACE3-native fracture toggle, called directly rather than through the generic Injury/backend-
 * interface dispatch (same reasoning as fnc_applyCardiacState.sqf) - fracture has no place in the
 * backend-agnostic Injury object.
 *
 * Unlike kat_compat's own applyFracture (a real 0-3 Simple/Compound/Comminuted severity scale,
 * tracked in KAT's own entirely separate `kat_surgery_fractures` variable), ACE's real mechanism
 * (REFERENCES.md has the full traced source) is a plain per-limb state: `0` none, `1` fractured,
 * `-1` fractured-but-splinted (set only by `ace_medical_treatment_fnc_splintLocal` - not something
 * this dialog stages, since it's a live treatment outcome, not an authored injury). This function
 * only ever writes `0`/`1`.
 *
 * Dispatched via CBA_fnc_targetEvent to fnc_applyFractureLocal.sqf, same reasoning as
 * fnc_applyInjury.sqf: `ace_medical_engine_fnc_updateDamageEffects` (which this needs to call to
 * make the real limping/sprint-block effects actually apply) requires `local _unit`
 * (REFERENCES.md), and this can be reached from a server-authoritative remoteExec with no
 * guarantee the target is local to the server.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: LimbId <STRING> - see DESIGN.md §4.1 / INJURY_CODES.md §1 - must be an arm or a leg
 * 2: Fractured <BOOL> (default false)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_limb", ["_fractured", false]];

if (isNull _unit) exitWith {};

["afcm_sim_ace_applyFractureLocal", [_unit, _limb, _fractured], _unit] call CBA_fnc_targetEvent;
