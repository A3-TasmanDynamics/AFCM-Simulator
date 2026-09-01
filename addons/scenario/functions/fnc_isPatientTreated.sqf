/*
 * Author: Tasman Dynamics
 * Whole-patient "treated" check for the Medical Tent completion monitor
 * (fnc_startMedicalTentMonitor.sqf) - true if EITHER real medical state says so, OR someone
 * manually marked the patient treated (the "Both" detection mode - auto-detect doesn't cover every
 * backend/situation, e.g. no medical backend active at all, so a manual override always works too).
 *
 * Auto-detect: conscious (`lifeState == "ALIVE"` - vanilla engine command, confirmed real, same as
 * ace_compat/kat_compat's own fnc_getState.sqf already relies on) AND no open-wound bleeding on any
 * of the 6 limbs (INJURY_CODES.md's limb id list) - checked via the existing
 * afcm_sim_fnc_backend_getState per-limb `limbBleeding` field (DESIGN.md §4.2's live-status API,
 * the same one the Injury Editor's own live status readout already uses), looped once per limb
 * since that field is inherently per-limb, not whole-unit.
 *
 * Manual override: afcm_sim_scenario_fnc_serverMarkTreated sets AFCM_SIM_treated=true on the unit -
 * the "Mark as Treated" addAction every spawned patient gets alongside "Edit Injuries".
 *
 * Arguments:
 * 0: Patient unit <OBJECT>
 *
 * Return Value:
 * Bool
 *
 * Public: No
*/

params ["_unit"];

if (isNull _unit) exitWith { false };
if (_unit getVariable ["AFCM_SIM_treated", false]) exitWith { true };
if !(alive _unit) exitWith { false };
if (lifeState _unit != "ALIVE") exitWith { false };

private _limbs = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"];
private _stillBleeding = _limbs findIf {
    private _state = [_unit, _x] call afcm_sim_fnc_backend_getState;
    _state getOrDefault ["limbBleeding", false]
} != -1;

!_stillBleeding
