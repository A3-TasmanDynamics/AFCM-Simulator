/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's "View Live State" button - author-new-patient
 * mode only (hidden entirely in edit mode, which already auto-starts this same readout on open -
 * fnc_injuryAuthor_init.sqf). Disabled until AFCM_SIM_UI_lastSpawnedPatient exists
 * (fnc_injuryAuthor_onPatientSpawned.sqf, the callback Apply & Spawn Patient triggers once the
 * server confirms a real unit exists), so this only ever runs with a real unit in hand.
 *
 * Deliberately reuses AFCM_SIM_UI_targetUnit/fnc_injuryAuthor_refreshState.sqf as-is rather than a
 * parallel implementation - that function already reads AFCM_SIM_UI_targetUnit +
 * AFCM_SIM_UI_activeLimb and writes the status readout (idc 35), exactly what's needed here.
 * AFCM_SIM_UI_authorNewPatient is deliberately left `true` (this doesn't switch the dialog into
 * edit mode - Apply stays "Apply & Spawn Patient", ChooseLocation stays visible, and
 * fnc_injuryAuthor_cleanup.sqf's own authorNewPatient check still correctly saves the close-time
 * draft to the missionNamespace new-patient slot, not onto this already-spawned unit) - only the
 * status readout is being pointed at a real unit.
 *
 * Clicking it again after spawning a second patient re-targets the same running PFH at whichever
 * unit is now AFCM_SIM_UI_lastSpawnedPatient, rather than stacking a second one - guarded by
 * AFCM_SIM_UI_statePFH already being set.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: View Live State button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlViewLiveState"];

disableSerialization;

private _lastSpawned = missionNamespace getVariable ["AFCM_SIM_UI_lastSpawnedPatient", objNull];
if (isNull _lastSpawned) exitWith {
    ["Injury Author", "No patient has been spawned yet."] call afcm_sim_ui_fnc_showToast;
};

missionNamespace setVariable ["AFCM_SIM_UI_targetUnit", _lastSpawned];

private _handle = missionNamespace getVariable ["AFCM_SIM_UI_statePFH", -1];
if (_handle == -1) then {
    // 25611 = IDD_AFCM_SIM_INJURYAUTHOR (addons/ui/config.cpp) - hardcoded since #defines aren't
    // available in SQF; keep in sync if that IDD ever changes.
    private _display = findDisplay 25611;
    private _pfhHandle = [
        { params ["_args", "_handle"]; [_args, _handle] call afcm_sim_ui_fnc_injuryAuthor_refreshState; },
        0.5,
        [_display]
    ] call CBA_fnc_addPerFrameHandler;
    missionNamespace setVariable ["AFCM_SIM_UI_statePFH", _pfhHandle];
};

call afcm_sim_ui_fnc_injuryAuthor_refreshState;
