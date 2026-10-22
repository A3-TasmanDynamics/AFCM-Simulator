/*
 * Author: Tasman Dynamics
 * Adds the "Edit Injuries (AFCM-Simulator)" scroll-wheel action to a patient unit. Run via
 * remoteExec (target 0 = everyone, JIP-persisted) from afcm_sim_spawner_fnc_spawnPatient - addAction
 * is inherently local to whichever machine calls it, so every client (present and JIP) needs to run
 * this itself for the action to actually show up for them. Vanilla addAction, not the ACE
 * interaction menu (REFERENCES.md) - AFCM-Simulator's own UI never depends on ACE being present
 * (DESIGN.md §2.4).
 *
 * Condition is opt-in gated behind afcm_sim_requireInjuryEditPermission (default false, unrestricted
 * - unchanged behaviour unless a mission maker turns it on). When on, a player needs
 * AFCM_SIM_canEditInjuries set on themselves first (fnc_addTerminalAction.sqf's "AFCM: Authorize
 * Injury Editing" action, revocable via its own "AFCM: Revoke Injury Editing"). The condition string
 * itself reads afcm_sim_requireInjuryEditPermission live, not a value baked in once at add-time -
 * condition strings are re-evaluated every time a player scrolls regardless, so this also means a
 * mission maker toggling the CBA setting mid-mission takes effect immediately for every already-
 * spawned patient, not just ones spawned after the toggle.
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

private _condition = "!afcm_sim_requireInjuryEditPermission || {player getVariable ['AFCM_SIM_canEditInjuries', false]}";

_unit addAction [
    "<t color='#c1272d'>AFCM: Edit Injuries</t>",
    {
        diag_log text format ["[AFCM-Simulator][UI] Edit Injuries action used on %1.", _this select 0];
        [_this select 0] call afcm_sim_ui_fnc_injuryAuthor_open;
    },
    [],
    1.5,
    true,
    true,
    "",
    _condition,
    5
];

diag_log text format ["[AFCM-Simulator][UI] Edit Injuries action added to %1.", _unit];
