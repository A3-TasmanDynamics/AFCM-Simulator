/*
 * Author: Tasman Dynamics
 * KAT-specific (no ACE equivalent) - sets the real `kat_breathing_pneumothorax`/
 * `kat_breathing_Hemopneumothorax`/`kat_breathing_Tensionpneumothorax` variables and applies them
 * via the real `kat_breathing_fnc_handleBreathing` call (KAT_COMPAT.md §4/INJURY_CODES.md §6 -
 * setting the variables alone isn't sufficient, confirmed from the prior working prototype). Not
 * per-limb - pneumothorax is a torso-wide condition, unlike fracture.
 *
 * Not part of the generic backend interface (afcm_sim_fnc_backend_*) since this has no meaning
 * under ACE alone or AFCM - called directly by
 * afcm_sim_scenario_fnc_serverApplyKatPneumothorax, only reachable from the injury editor UI when
 * KAT is confirmed to be the active backend.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: State <NUMBER> - 0=None, 1=Simple Pneumothorax, 2=Hemopneumothorax, 3=Tension Pneumothorax
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_state"];

if (isNull _unit) exitWith {};

private _severity = 0;
private _hemo = false;
private _tension = false;

switch (_state) do {
    case 1: { _severity = 2; };
    case 2: { _severity = 2; _hemo = true; };
    case 3: { _severity = 2; _tension = true; };
};

_unit setVariable ["kat_breathing_pneumothorax", _severity, true];
_unit setVariable ["kat_breathing_Hemopneumothorax", _hemo, true];
_unit setVariable ["kat_breathing_Tensionpneumothorax", _tension, true];

[_unit] call kat_breathing_fnc_handleBreathing;
