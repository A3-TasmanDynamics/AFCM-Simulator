/*
 * Author: Tasman Dynamics
 * Applies a Preset's optional katExtras element (fnc_exportPatientState.sqf/
 * fnc_parseExportedPreset.sqf - `[fractures <ARRAY[6]>, pneumothoraxType, airwayType,
 * cardiacRhythm]`) to a unit, via the same server-authoritative handlers the injury editor's own
 * Fracture/Pneumothorax/Airway/Cardiac State controls use
 * (afcm_sim_scenario_fnc_serverApplyFracture/serverApplyKatPneumothorax/serverApplyKatAirway/
 * serverApplyCardiacState). Factored out into its own function specifically so
 * fnc_serverApplyPreset.sqf (Preset Library Apply) and afcm_sim_spawner_fnc_spawnPatient (Eden AFCM
 * Patient module's Injury Preset Import attribute, applied to a freshly-spawned patient) can both
 * reuse it instead of duplicating the fracture-array walk/pneumothorax/airway/cardiac dispatch.
 *
 * Name kept as "katExtras" even though serverApplyFracture (and cardiac state) aren't KAT-exclusive
 * - a full rename would touch this shape's variable name across many files (AFCM_SIM_UI_
 * stagedKatExtras, fnc_readLiveKatExtras.sqf, the Preset export format's own 7th element) for no
 * functional gain; noted here plainly rather than left unexplained.
 *
 * Every one of the four handlers already no-ops safely (with a diag_log) if its backend isn't
 * actually active/supported - a KAT-exported preset's pneumothorax/airway entries are simply
 * skipped under a plain-ACE session (no ACE equivalent, REFERENCES.md), while fracture and cardiac
 * rhythm (> 0 meaning "in arrest"/"fractured" either way) still apply through whichever backend's
 * own real implementation is active. Only non-zero/non-default entries trigger a call at all,
 * matching afcm_sim_kat_fnc_applyFracture's own "0 = no fracture" convention.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: katExtras <ARRAY> - `[fractures <ARRAY[6]>, pneumothoraxType, airwayType, cardiacRhythm]`, or
 *    [] to apply nothing
 *
 * Return Value:
 * None
 *
 * Public: Yes
*/

params ["_unit", ["_katExtras", []]];

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};
if (count _katExtras != 4) exitWith {};

_katExtras params [["_fractures", [0, 0, 0, 0, 0, 0], [[]]], ["_pneumoType", 0], ["_airwayType", 0], ["_rhythm", 0]];

private _limbOrder = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"];
{
    if (_x > 0) then {
        private _limb = _limbOrder select _forEachIndex;
        if (_limb in ["leftArm", "rightArm", "leftLeg", "rightLeg"]) then {
            [_unit, _limb, _x] call afcm_sim_scenario_fnc_serverApplyFracture;
        };
    };
} forEach _fractures;

if (_pneumoType > 0) then { [_unit, _pneumoType] call afcm_sim_scenario_fnc_serverApplyKatPneumothorax; };
if (_airwayType > 0) then { [_unit, _airwayType] call afcm_sim_scenario_fnc_serverApplyKatAirway; };
if (_rhythm > 0) then { [_unit, _rhythm] call afcm_sim_scenario_fnc_serverApplyCardiacState; };
