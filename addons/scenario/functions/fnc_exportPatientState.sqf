/*
 * Author: Tasman Dynamics
 * Builds a shareable export string from a live patient's currently-applied AFCM injuries
 * (AFCM_SIM_appliedInjuries, tracked per-limb by afcm_sim_fnc_backend_applyInjury.sqf whenever it
 * dispatches to a backend), PLUS current KAT-only extras and cardiac state -
 * fracture/pneumothorax/airway/cardiac rhythm (afcm_sim_scenario_fnc_readLiveKatExtras). "The Job":
 * a controller hand-authors one patient (injuries AND KAT extras) via the normal Edit Injuries
 * flow, then exports the result straight into an Eden AFCM Patient module's Injury Preset Import
 * attribute (or the Preset Library) to reuse it - e.g. building a custom MCI entirely out of
 * individually-authored patients.
 *
 * The actual string-building (shape choice: bare injuries array vs. `[injuries, katExtras]`) is
 * factored into afcm_sim_scenario_fnc_exportInjuries - shared with the injury author dialog's own
 * Export button, which exports directly from its staged arrays rather than a live unit's variables.
 *
 * Base injuries deliberately read back only AFCM's own applied-injury bookkeeping, not live
 * ACE/KAT wound state - there's no reliable reverse mapping from ACE's own wound classes back to
 * this addon's simplified woundType strings (gunshot/shrapnel/blast), so anything applied through
 * this addon's own pipeline is tracked at the point of application instead
 * (fnc_backend_applyInjury.sqf) and read straight back here.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 *
 * Return Value:
 * Exported string <STRING> - `str _injuries` or `str [_injuries, _katExtras]`, "" if the unit has
 * neither AFCM-applied injuries nor any KAT extras/cardiac state set
 *
 * Public: Yes
*/

params ["_unit"];

if (isNull _unit) exitWith { "" };

private _injuries = _unit getVariable ["AFCM_SIM_appliedInjuries", []];
private _katExtras = [_unit] call afcm_sim_scenario_fnc_readLiveKatExtras;

if (_injuries isEqualTo [] && {_katExtras isEqualTo [[0, 0, 0, 0, 0, 0], 0, 0, 0]}) exitWith { "" };

[_injuries, _katExtras] call afcm_sim_scenario_fnc_exportInjuries
