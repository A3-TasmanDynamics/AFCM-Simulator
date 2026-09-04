/*
 * Author: Tasman Dynamics
 * Pre-loads RscDisplayAFCM_SIM_InjuryAuthor's staged arrays from a live, already-spawned unit's
 * current AFCM-applied injuries (AFCM_SIM_appliedInjuries, tracked per-limb by
 * afcm_sim_fnc_backend_applyInjury.sqf - already in the exact staged-array shape) and its live KAT
 * extras/cardiac state (afcm_sim_scenario_fnc_readLiveKatExtras) - what makes edit-mode ("AFCM: Edit
 * Injuries" on a spawned patient) start from that patient's actual current state instead of an
 * empty form.
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

if (isNull _unit) exitWith {
    missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", []];
    missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
};

missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", _unit getVariable ["AFCM_SIM_appliedInjuries", []]];
missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", [_unit] call afcm_sim_scenario_fnc_readLiveKatExtras];
