/*
 * Author: Tasman Dynamics
 * Adds the "Export Patient State" scroll-wheel action to a patient unit. Run via remoteExec
 * (target 0 = everyone, JIP-persisted) from afcm_sim_spawner_fnc_spawnPatient, same reasoning as
 * fnc_addInjuryEditorAction.sqf - addAction is inherently local to whichever machine calls it, so
 * every client (present and JIP) needs to run this itself for the action to actually show up.
 *
 * The action itself runs entirely locally, no remoteExec needed - fnc_exportPatientState.sqf reads
 * back AFCM_SIM_appliedInjuries (a publicVariable'd unit variable already replicated to every
 * client, fnc_backend_applyInjury.sqf) plus live KAT extras/cardiac state (own real variables,
 * already public by nature of how they're set). Copies the result straight to the OS clipboard via
 * the real `copyToClipboard` command, ready to paste into an Eden AFCM Patient module's Injury
 * Preset Import attribute or the Preset Library's own Import field.
 *
 * Arguments:
 * 0: Patient unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_unit"];

if (isNull _unit) exitWith {};

_unit addAction [
    "<t color='#c1272d'>AFCM: Export Patient State</t>",
    {
        params ["_target"];
        private _exported = [_target] call afcm_sim_scenario_fnc_exportPatientState;
        if (_exported isEqualTo "") exitWith {
            ["Export Patient State", "No AFCM-applied injuries or KAT extras/cardiac state on this patient yet."] call afcm_sim_ui_fnc_showToast;
        };
        copyToClipboard _exported;
        ["Export Patient State", "Copied to clipboard - paste into a module's Injury Preset Import attribute or the Preset Library."] call afcm_sim_ui_fnc_showToast;
    },
    [],
    1.2,
    true,
    true,
    "",
    "true",
    5
];
