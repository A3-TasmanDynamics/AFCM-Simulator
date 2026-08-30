/*
 * Author: Tasman Dynamics
 * ACE3/KAT/ACM backend implementation of the reset interface function. Wipes all wounds/damage/
 * drugs via the real, confirmed `ace_medical_fnc_fullHeal` (REFERENCES.md), then re-locks the unit
 * back into the "unconscious training patient" baseline (DESIGN.md §5/§2.5 — patients always spawn
 * unconscious; a reset should hand back that same starting state, not a fully awake, healthy one).
 *
 * Re-lock uses `ace_medical_fnc_setUnconscious`, not the engine's own `setUnconscious` command -
 * see fnc_setUnconscious.sqf for why the engine command alone doesn't actually stop ACE's own AI
 * from treating the unit.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit"];

if (isNull _unit) exitWith {};

[_unit] call ace_medical_fnc_fullHeal;
[_unit] call afcm_sim_ace_fnc_setUnconscious;
