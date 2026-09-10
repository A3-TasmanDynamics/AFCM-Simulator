/*
 * Author: Tasman Dynamics
 * Resolves an AFCM_SIM_ModulePatientPlacement logic's attributes (Casualty Type/Session Name/
 * Training Preset/Injury Preset Import, addons/eden/config.cpp) into what
 * afcm_sim_spawner_fnc_spawnPatient actually needs - factored out of fnc_module_patientPlacement.sqf
 * so both real spawn paths (immediate auto-spawn when nothing's synced to the module, and the
 * deferred on-demand spawn once something is - fnc_serverSpawnFromTerminal.sqf) share exactly one
 * implementation of the Training-Preset-vs-paste precedence, rather than two that could drift.
 *
 * Training Preset wins over Injury Preset Import whenever it's set to anything but "None" (index 0)
 * - the combo's own default option label ("None (use paste below)") already frames the paste field
 * as the None-only fallback, not something the combo overrides. The combo's value is a 1-based
 * position into afcm_sim_scenario_fnc_getBuiltinPresets.sqf's own array (config.cpp's own comment on
 * AFCM_SIM_TrainingPreset has the full "why an index, not a duplicated id" reasoning) - keep both in
 * sync if that array's order/count ever changes.
 *
 * Arguments:
 * 0: Logic <OBJECT> - the placed AFCM_SIM_ModulePatientPlacement module
 *
 * Return Value:
 * [Injuries <ARRAY of Injury HASHMAP>, Casualty Type <NUMBER>, Session Label <STRING>,
 *  katExtras <ARRAY>]
 *
 * Public: No
*/

params ["_logic"];

private _casualtyType = _logic getVariable ["AFCM_SIM_casualtyType", afcm_sim_defaultCasualtyType];
private _sessionLabel = _logic getVariable ["AFCM_SIM_sessionName", ""];

private _injuries = [];
private _katExtras = [];

private _fnc_buildInjuries = {
    params ["_rawInjuries"];
    _rawInjuries apply {
        _x params ["_limb", "_woundType", "_severity", "_bleeding"];
        [_limb, _woundType, _severity, _bleeding] call afcm_sim_scenario_fnc_buildInjury
    }
};

private _trainingPresetIdx = _logic getVariable ["AFCM_SIM_trainingPreset", 0];
if (_trainingPresetIdx > 0) then {
    private _builtins = call afcm_sim_scenario_fnc_getBuiltinPresets;
    private _preset = _builtins param [_trainingPresetIdx - 1, []];
    if (_preset isEqualTo []) then {
        diag_log text format ["[AFCM-Simulator] AFCM Patient module - Training Preset index %1 doesn't match a built-in preset (list changed?), spawning clean instead.", _trainingPresetIdx];
    } else {
        _injuries = [_preset select 4] call _fnc_buildInjuries;
        _katExtras = _preset param [6, []];
    };
} else {
    private _importString = (_logic getVariable ["AFCM_SIM_injuryPresetImport", ""]) call CBA_fnc_trim;
    if (_importString != "") then {
        diag_log text format ["[AFCM-Simulator] AFCM Patient module - Injury Preset Import attribute: %1", _importString];
        private _cleaned = [_importString] call afcm_sim_scenario_fnc_parseExportedPreset;
        if (_cleaned isEqualTo []) then {
            diag_log text "[AFCM-Simulator] AFCM Patient module - Injury Preset Import didn't parse, spawning clean instead.";
        } else {
            _injuries = [_cleaned select 1] call _fnc_buildInjuries;
            _katExtras = _cleaned select 5;
            diag_log text format ["[AFCM-Simulator] AFCM Patient module - parsed %1 injuries, katExtras=%2.", count _injuries, _katExtras];
        };
    };
};

[_injuries, _casualtyType, _sessionLabel, _katExtras]
