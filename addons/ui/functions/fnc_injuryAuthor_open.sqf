/*
 * Author: Tasman Dynamics
 * Opens RscDisplayAFCM_SIM_InjuryAuthor. Two modes, told apart by whether a target unit is given:
 *  - Edit an already-spawned patient (_targetUnit real) - if fnc_injuryAuthor_cleanup.sqf left a
 *    same-session draft on this exact unit (AFCM_SIM_UI_hasDraft), restores that instead so
 *    backing out of the dialog and reopening on the same patient picks up right where you left
 *    off; otherwise pre-loads its current real injuries/KAT extras
 *    (fnc_injuryAuthor_loadFromUnit.sqf).
 *  - Author a brand-new patient (_targetUnit objNull, the Ctrl+Shift+I keybind's own call) -
 *    restores fnc_injuryAuthor_cleanup.sqf's own AFCM_SIM_UI_draftNewPatientInjuries/KatExtras if
 *    one exists (same "pick up where you left off" reasoning, same-session); otherwise, if
 *    afcm_sim_rememberLastInjuries is on, auto-restores whatever was last actually applied/spawned
 *    (profileNamespace AFCM_SIM_lastUsedInjuries/lastUsedKatExtras, written by
 *    fnc_injuryAuthor_onApply.sqf's author-new-patient branch); otherwise starts empty.
 *    fnc_injuryAuthor_onClearAll.sqf is the "quick clear/reset" the CBA setting's own tooltip
 *    promises for wiping that remembered set.
 *
 * _preserveStaged (2nd param) skips both of the above entirely - used only by
 * fnc_injuryAuthor_loadPresetArrays.sqf, which sets AFCM_SIM_UI_stagedInjuries/stagedKatExtras
 * itself right before reopening this dialog and would otherwise have its freshly-loaded preset
 * immediately clobbered by the normal open-time reset/restore logic.
 *
 * AFCM_SIM_UI_targetUnit/targetUnits/authorNewPatient are stashed in plain (client-local, unsynced)
 * missionNamespace variables rather than threaded through dialog params, same reasoning as the old
 * fnc_limbSelect_open.sqf - RscDisplay dialogs don't take arguments; every downstream step in this
 * flow reads them back from there.
 *
 * Arguments:
 * 0: Target unit <OBJECT> (default objNull - author-new-patient mode)
 * 1: Preserve staged arrays <BOOL> (default false)
 *
 * Return Value:
 * Bool - result of createDialog
 *
 * Public: Yes
*/

params [["_targetUnit", objNull], ["_preserveStaged", false]];

missionNamespace setVariable ["AFCM_SIM_UI_targetUnit", _targetUnit];
missionNamespace setVariable ["AFCM_SIM_UI_targetUnits", []];
missionNamespace setVariable ["AFCM_SIM_UI_authorNewPatient", isNull _targetUnit];

if !(_preserveStaged) then {
    if (isNull _targetUnit) then {
        if (missionNamespace getVariable ["AFCM_SIM_UI_draftNewPatientValid", false]) then {
            missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", missionNamespace getVariable ["AFCM_SIM_UI_draftNewPatientInjuries", []]];
            missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", missionNamespace getVariable ["AFCM_SIM_UI_draftNewPatientKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]]];
            // Spawn location deliberately left untouched here - it's part of the same in-progress
            // session the draft came from; resetting it would re-disable Apply for no reason.
        } else {
            if (afcm_sim_rememberLastInjuries) then {
                missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", profileNamespace getVariable ["AFCM_SIM_lastUsedInjuries", []]];
                missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", profileNamespace getVariable ["AFCM_SIM_lastUsedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]]];
            } else {
                missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", []];
                missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];
            };
            missionNamespace setVariable ["AFCM_SIM_UI_authorSpawnPos", []];
        };
    } else {
        if (_targetUnit getVariable ["AFCM_SIM_UI_hasDraft", false]) then {
            missionNamespace setVariable ["AFCM_SIM_UI_stagedInjuries", _targetUnit getVariable ["AFCM_SIM_UI_draftInjuries", []]];
            missionNamespace setVariable ["AFCM_SIM_UI_stagedKatExtras", _targetUnit getVariable ["AFCM_SIM_UI_draftKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]]];
        } else {
            [_targetUnit] call afcm_sim_ui_fnc_injuryAuthor_loadFromUnit;
        };
    };
};

private _result = createDialog "RscDisplayAFCM_SIM_InjuryAuthor";
diag_log text format ["[AFCM-Simulator][UI] injuryAuthor_open for %1 - createDialog result: %2.", _targetUnit, _result];
_result
