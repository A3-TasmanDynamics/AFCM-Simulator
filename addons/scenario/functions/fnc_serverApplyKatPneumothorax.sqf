/*
 * Author: Tasman Dynamics
 * Server-side handler for KAT-specific pneumothorax state (INJURY_CODES.md §6) - not part of the
 * generic Injury object/backend interface. Same reasoning/re-check pattern as
 * fnc_serverApplyKatFracture.sqf.
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

if !(isServer) exitWith {};
if (isNull _unit) exitWith {};

if ((missionNamespace getVariable ["AFCM_SIM_activeBackend", ""]) != "kat") exitWith {
    diag_log text "[AFCM-Simulator] serverApplyKatPneumothorax ignored - kat is not the active backend.";
};

[_unit, _state] call afcm_sim_kat_fnc_applyPneumothorax;
