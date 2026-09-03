/*
 * Author: Tasman Dynamics
 * Builds a shareable export string from a live patient's currently-applied AFCM injuries
 * (AFCM_SIM_appliedInjuries, tracked per-limb by afcm_sim_fnc_backend_applyInjury.sqf whenever it
 * dispatches to a backend), PLUS current KAT-only extras and cardiac state -
 * fracture/pneumothorax/airway/cardiac rhythm. "The Job": a controller hand-authors one patient
 * (injuries AND KAT extras) via the normal Edit Injuries flow, then exports the result straight
 * into an Eden AFCM Patient module's Injury Preset Import attribute (or the Preset Library) to
 * reuse it - e.g. building a custom MCI entirely out of individually-authored patients.
 *
 * Deliberately a bare array on request, NOT a full Preset envelope
 * (id/name/author/description/tags) the way fnc_exportPreset.sqf's own output is - this is a
 * one-patient, throwaway export meant to be pasted straight back into another module/patient, and
 * the envelope fields were pure noise for that. Exported shape: `str _injuries` when there are no
 * KAT extras/cardiac state to carry (so a base-injuries-only export is exactly the injuries array,
 * nothing wrapping it), or `str [_injuries, _katExtras]` when there are.
 * fnc_parseExportedPreset.sqf (shared with the Preset Library's own Import, which still expects
 * the full Preset envelope from its own Export) tells the two shapes apart by element count and
 * reads either one back.
 *
 * Base injuries deliberately read back only AFCM's own applied-injury bookkeeping, not live
 * ACE/KAT wound state - there's no reliable reverse mapping from ACE's own wound classes back to
 * this addon's simplified woundType strings (gunshot/shrapnel/blast), so anything applied through
 * this addon's own pipeline is tracked at the point of application instead
 * (fnc_backend_applyInjury.sqf) and read straight back here.
 *
 * KAT extras/cardiac state, unlike base injuries, ARE read directly from live state
 * (kat_surgery_fractures/kat_breathing_pneumothorax(+hemo/tension)/kat_airway_obstruction
 * (+occluded)/kat_circulation_cardiacArrestType, falling back to the plain ACE
 * ace_medical_vitals_inCardiacArrest flag if no KAT rhythm is set) rather than needing their own
 * applied-state tracking - these are AFCM/KAT's own custom variables, not part of ACE's generic
 * wound system, so there's no reverse-mapping problem for them the way there is for base injuries.
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

private _fractures = _unit getVariable ["kat_surgery_fractures", [0, 0, 0, 0, 0, 0]];

private _pneumoSeverity = _unit getVariable ["kat_breathing_pneumothorax", 0];
private _hemothorax = _unit getVariable ["kat_breathing_hemopneumothorax", false];
private _tensionPneumothorax = _unit getVariable ["kat_breathing_tensionpneumothorax", false];
private _pneumoType = 0;
if (_tensionPneumothorax) then {
    _pneumoType = 3;
} else {
    if (_hemothorax) then { _pneumoType = 2; } else {
        if (_pneumoSeverity > 0) then { _pneumoType = 1; };
    };
};

private _airwayType = 0;
if (_unit getVariable ["kat_airway_occluded", false]) then {
    _airwayType = 2;
} else {
    if (_unit getVariable ["kat_airway_obstruction", false]) then { _airwayType = 1; };
};

// KAT's own rhythm variable wins when set (real detail); a plain ACE arrest with no KAT rhythm
// still exports as rhythm 1 - "any value > 0 just means in arrest" under ACE, matching
// fnc_serverApplyCardiacState.sqf's own semantics.
private _rhythm = _unit getVariable ["kat_circulation_cardiacArrestType", 0];
if (_rhythm == 0 && {_unit getVariable ["ace_medical_vitals_inCardiacArrest", false]}) then {
    _rhythm = 1;
};

private _katExtras = [_fractures, _pneumoType, _airwayType, _rhythm];
private _hasKatExtras = _katExtras isNotEqualTo [[0, 0, 0, 0, 0, 0], 0, 0, 0];

if (_injuries isEqualTo [] && {!_hasKatExtras}) exitWith { "" };

if (_hasKatExtras) then {
    str [_injuries, _katExtras]
} else {
    str _injuries
}
