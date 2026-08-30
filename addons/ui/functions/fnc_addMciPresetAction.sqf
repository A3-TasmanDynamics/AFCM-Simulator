/*
 * Author: Tasman Dynamics
 * Adds the "Assign MCI Preset" scroll-wheel action to every unit in a freshly-spawned MCI batch
 * (afcm_sim_zeus_fnc_module_mciSpawner) - clicking it on ANY one of them opens the Preset Library
 * (RscDisplayAFCM_SIM_PresetLibrary) in batch mode, applying whichever preset gets picked to the
 * WHOLE group at once via AFCM_SIM_UI_targetUnits (plural - fnc_presetLibrary_onApply.sqf checks
 * this before falling back to the normal single-unit AFCM_SIM_UI_targetUnit).
 *
 * Run via remoteExec (target 0 = everyone, JIP-persisted) - addAction is inherently local to
 * whichever machine calls it, same reasoning as fnc_addInjuryEditorAction.sqf, which every spawned
 * patient (including these) also already gets independently for per-patient fine-tuning.
 *
 * Arguments:
 * 0: Units <ARRAY of OBJECT> - the whole spawned batch
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_units"];

{
    private _unit = _x;
    if !(isNull _unit) then {
        _unit addAction [
            "<t color='#c1272d'>AFCM: Assign MCI Preset</t>",
            {
                params ["", "", "", "_units"];
                missionNamespace setVariable ["AFCM_SIM_UI_targetUnit", objNull];
                missionNamespace setVariable ["AFCM_SIM_UI_targetUnits", _units];
                createDialog "RscDisplayAFCM_SIM_PresetLibrary";
            },
            _units,
            1.5,
            true,
            true,
            "",
            "true",
            5
        ];
    };
} forEach _units;

diag_log text format ["[AFCM-Simulator][UI] Assign MCI Preset action added to %1 unit(s).", count _units];
