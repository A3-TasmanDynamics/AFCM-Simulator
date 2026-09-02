/*
 * Author: Tasman Dynamics
 * KAT-specific pneumothorax infliction, called directly rather than through the generic Injury/
 * backend-interface dispatch (INJURY_CODES.md §6 / KAT_COMPAT.md §4) - it's a torso-wide
 * condition, not a per-limb wound, with no equivalent in the backend-agnostic Injury object.
 *
 * Real, confirmed mechanism (KAT-Advanced-Medical/KAM, addons/breathing/functions/
 * fnc_handleBreathing.sqf + fnc_inflictAdvancedPneumothorax.sqf, both fetched directly this pass):
 * `kat_breathing_pneumothorax` is a severity Number on a confirmed 0-4 scale, genuinely continuous -
 * `handleBreathing`'s own breathing-rate calculation scales directly off `_pneumothorax / 4`, not
 * just an on/off flag - and KAT's own real infliction function sets it to exactly `4` for any
 * *advanced* case specifically (Hemo/Tension). A plain Simple Pneumothorax is deliberately given a
 * lower value (2) here instead of also maxing out at 4 - KAT has no real "basic pneumothorax"
 * infliction function of its own to confirm an exact number against (only the advanced path exists
 * in its source), but reusing severity 4 for Simple would contradict handleBreathing's own
 * continuous-severity model and this function's own prior claim that 4 means "advanced only".
 * Alongside the severity, two mutually-exclusive booleans (`kat_breathing_hemopneumothorax`/
 * `kat_breathing_tensionpneumothorax` - KAT's own infliction function explicitly prevents both
 * being true on the same patient at once).
 *
 * Setting the variables alone isn't sufficient - `kat_breathing_fnc_handleBreathing` has to be
 * called afterward to actually apply the state, and Hemothorax specifically also needs
 * `kat_circulation_fnc_updateInternalBleeding` (confirmed from `fnc_inflictAdvancedPneumothorax.sqf`,
 * which calls it right after setting `hemopneumothorax` - not `handleBreathing` at all for that
 * path). That function is what actually turns the hemopneumothorax flag into a live
 * internal-bleeding rate (`kat_circulation_internalBleeding`) that drains the patient's real ACE
 * blood volume (`ace_medical_bloodVolume`) over time - called unconditionally alongside
 * handleBreathing so it also correctly zeroes the rate back out when switching away from
 * Hemopneumothorax, not just when setting it.
 *
 * Both of those calls are dispatched to whichever machine `_unit` is actually local to, via a CBA
 * event (`"afcm_sim_applyKatPneumothoraxLocal"`, `fnc_preInit.sqf`) rather than called directly -
 * this function is reached from a server-authoritative remoteExec with no guarantee the target is
 * local to the server, same real fix as `afcm_sim_ace_fnc_applyInjury`'s own dispatch (see that
 * function's header, ACE_COMPAT.md, for the full "why" - `ace_medical_fnc_addDamageToUnit`
 * requiring `local _unit` is the confirmed case; KAT's own breathing/circulation functions get the
 * same treatment here since KAT's own source always wraps this class of state-mutating call in a
 * "...Local"-suffixed function dispatched via `CBA_fnc_targetEvent`, e.g.
 * addons/airway/functions/fnc_treatmentAdvanced_airway.sqf). The `setVariable`s below stay in the
 * dispatcher itself - `setVariable` with public sync (the `true` third argument) is safe to call
 * from anywhere, it just broadcasts.
 *
 * Deliberately deterministic, unlike KAT's own real infliction function (which rolls a random
 * chance and a random hemo-vs-tension split) - an instructor picking a type here should get
 * exactly what they picked, not a dice roll.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Type <NUMBER> - 0=None, 1=Simple Pneumothorax, 2=Hemopneumothorax, 3=Tension Pneumothorax
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", ["_type", 0]];

if (isNull _unit) exitWith {};

private _severity = [0, 2, 4, 4] param [_type, 0];

_unit setVariable ["kat_breathing_pneumothorax", _severity, true];
_unit setVariable ["kat_breathing_hemopneumothorax", _type == 2, true];
_unit setVariable ["kat_breathing_tensionpneumothorax", _type == 3, true];

["afcm_sim_applyKatPneumothoraxLocal", [_unit], _unit] call CBA_fnc_targetEvent;
