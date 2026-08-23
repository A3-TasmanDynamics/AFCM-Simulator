/*
 * Author: Tasman Dynamics
 * Adds the "Edit Injuries (AFCM-Simulator)" scroll-wheel action to a patient unit. Run via
 * remoteExec (target 0 = everyone, JIP-persisted) from afcm_sim_spawner_fnc_spawnPatient - addAction
 * is inherently local to whichever machine calls it, so every client (present and JIP) needs to run
 * this itself for the action to actually show up for them. Vanilla addAction, not the ACE
 * interaction menu (REFERENCES.md) - AFCM-Simulator's own UI never depends on ACE being present
 * (DESIGN.md §2.4).
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
    "<t color='#c1272d'>AFCM: Edit Injuries</t>",
    {
        diag_log text format ["[AFCM-Simulator][UI] Edit Injuries action used on %1.", _this select 0];
        [_this select 0] call afcm_sim_ui_fnc_limbSelect_open;
    },
    [],
    1.5,
    true,
    true,
    "",
    "true",
    5
];

diag_log text format ["[AFCM-Simulator][UI] Edit Injuries action added to %1.", _unit];
