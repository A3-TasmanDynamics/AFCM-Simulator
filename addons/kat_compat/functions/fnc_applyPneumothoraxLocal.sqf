/*
 * Author: Tasman Dynamics
 * CBA event handler ("afcm_sim_applyKatPneumothoraxLocal", fnc_preInit.sqf) - the half of
 * afcm_sim_kat_fnc_applyPneumothorax that has to run on whichever machine the target unit is
 * actually local to. See that function's own header for the full explanation of why this is
 * split out and dispatched via CBA_fnc_targetEvent rather than called directly.
 *
 * Arguments (from CBA_fnc_targetEvent, matching its real _params-becomes-_this shape):
 * 0: Target unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit"];

if (isNull _unit) exitWith {};

[_unit] call kat_breathing_fnc_handleBreathing;
// Unconditional, same as handleBreathing above - updateInternalBleeding reads the
// hemopneumothorax flag fresh each call, so this also correctly zeroes the internal-bleeding
// rate back out when switching away from Hemopneumothorax (to None or Tension), not just when
// setting it.
[_unit] call kat_circulation_fnc_updateInternalBleeding;
