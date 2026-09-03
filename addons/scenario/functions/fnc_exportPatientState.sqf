/*
 * Author: Tasman Dynamics
 * Builds a shareable export string (same shape/format as fnc_exportPreset.sqf) from a live
 * patient's currently-applied AFCM injuries (AFCM_SIM_appliedInjuries, tracked per-limb by
 * afcm_sim_fnc_backend_applyInjury.sqf whenever it dispatches to a backend). "The Job": a
 * controller hand-authors one patient's injuries via the normal Edit Injuries flow, then exports
 * the result straight into an Eden AFCM Patient module's Injury Preset Import attribute (or the
 * Preset Library) to reuse it - e.g. building a custom MCI entirely out of individually-authored
 * patients.
 *
 * Deliberately reads back only AFCM's own applied-injury bookkeeping, not live ACE/KAT wound
 * state - there's no reliable reverse mapping from ACE's own wound classes back to this addon's
 * simplified woundType strings (gunshot/shrapnel/blast), so anything applied through this addon's
 * own pipeline (manual, preset, randomized, MCI) is tracked at the point of application instead
 * (fnc_backend_applyInjury.sqf, already in the exact [limb, woundType, severity, bleeding] shape
 * fnc_getBuiltinPresets.sqf's injuries entries use, one per limb) and read straight back here. KAT-
 * only extras (fracture/pneumothorax/airway) and cardiac state are NOT included - the Preset format
 * itself has never carried them, so this doesn't regress anything, but a full "everything about
 * this patient" export isn't there yet either.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 *
 * Return Value:
 * Exported string <STRING> - same format fnc_exportPreset.sqf produces, "" if the unit has no
 * AFCM-applied injuries yet
 *
 * Public: Yes
*/

params ["_unit"];

if (isNull _unit) exitWith { "" };

private _injuries = _unit getVariable ["AFCM_SIM_appliedInjuries", []];

if (_injuries isEqualTo []) exitWith { "" };

private _preset = [
    format ["exported_%1", diag_tickTime],
    format ["Exported Patient (%1)", name _unit],
    profileName,
    "Exported from a live patient's current AFCM-applied injuries.",
    _injuries,
    ["exported"]
];

_preset call afcm_sim_scenario_fnc_exportPreset
