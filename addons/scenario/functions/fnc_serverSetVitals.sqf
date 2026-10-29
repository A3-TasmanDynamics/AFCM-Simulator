/*
 * Author: Tasman Dynamics
 * Server-side handler for setting a patient's blood volume/SpO2 (Injury Author dialog, edit mode
 * only - DESIGN.md §5 "Selectable Injuries"). Called via remoteExec from afcm_sim_ui, never called
 * directly by a client - DESIGN.md §6 requires interventions to be requests validated and applied
 * on the server, same pattern as fnc_serverReset.sqf/fnc_serverApplyPreset.sqf.
 *
 * Arguments:
 * 0: Target unit <OBJECT>
 * 1: Blood volume <NUMBER> - litres, real ACE3 ace_medical_bloodVolume range (0-6.0ish)
 * 2: SpO2 <NUMBER> - percent, real ACE3 ace_medical_spo2 range (0-100)
 * 3: Pain <NUMBER> - real ACE3 ace_medical_pain range (0-1)
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit", "_bloodVolume", "_spo2", "_pain"];

if !(isServer) exitWith {
    diag_log text "[AFCM-Simulator] serverSetVitals aborted - not running on the server.";
};
if (isNull _unit) exitWith {
    diag_log text "[AFCM-Simulator] serverSetVitals aborted - unit is objNull on the server.";
};

[_unit, _bloodVolume, _spo2, _pain] call afcm_sim_fnc_backend_setVitals;
