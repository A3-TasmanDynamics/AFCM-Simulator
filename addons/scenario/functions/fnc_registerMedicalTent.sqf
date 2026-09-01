/*
 * Author: Tasman Dynamics
 * Registers one Medical Tent's stretcher objects into the shared global stretcher list
 * (AFCM_SIM_medicalStretchers, a flat Array of [object, radius] pairs) and lazily starts the one
 * shared monitor loop (afcm_sim_scenario_fnc_startMedicalTentMonitor) the first time any tent
 * registers - every subsequent Medical Tent module just adds more stretchers to the same list
 * rather than spawning its own loop, which is what makes multiple simultaneous tents "free" (one
 * poll checks every session against every stretcher from every tent at once).
 *
 * Called from afcm_sim_eden_fnc_module_medicalTent (server-side only, per that module's own
 * isServer guard).
 *
 * Arguments:
 * 0: Stretchers <ARRAY of OBJECT> - the module's synced units
 * 1: Radius <NUMBER> (default 2) - how close (metres) a patient must be to any of these stretchers
 *    to count as "on" one
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_stretchers", ["_radius", 2]];

if !(isServer) exitWith {};

if (isNil "AFCM_SIM_medicalStretchers") then { AFCM_SIM_medicalStretchers = []; };

{
    if !(isNull _x) then { AFCM_SIM_medicalStretchers pushBack [_x, _radius]; };
} forEach _stretchers;

if (isNil "AFCM_SIM_medicalTentMonitorStarted") then {
    AFCM_SIM_medicalTentMonitorStarted = true;
    call afcm_sim_scenario_fnc_startMedicalTentMonitor;
};

diag_log text format ["[AFCM-Simulator] Medical Tent registered %1 stretcher(s) at radius %2m (total stretchers now %3).", count _stretchers, _radius, count AFCM_SIM_medicalStretchers];
