/*
 * Author: Tasman Dynamics
 * onUnload handler for RscDisplayAFCM_SIM_InjuryAuthor. Removes the per-frame handler
 * fnc_injuryAuthor_init.sqf started for the live status readout (edit mode only - author-new-patient
 * mode never starts one) - without this it would keep polling afcm_sim_fnc_backend_getState forever
 * after the dialog closes.
 *
 * Also snapshots whatever's currently staged as a "draft" so the next open on the same context
 * auto-restores it (fnc_injuryAuthor_open.sqf) - real feedback: closing the dialog (Close button,
 * Escape, or however) used to just drop whatever wasn't already applied, so a half-configured
 * patient was gone for good if you backed out to check something else first. Runs regardless of
 * how the dialog closed (same "no matter how it closed" reasoning fnc_mapPicker_cleanup.sqf already
 * uses), and commits the active limb's on-screen form first so an in-progress edit that was never
 * explicitly committed (e.g. Escape pressed mid-edit) is still captured.
 *
 * Author-new-patient mode has no live unit to hang the draft off, so it's a plain missionNamespace
 * var (AFCM_SIM_UI_draftNewPatientInjuries/KatExtras/Valid) - there's only ever one "new patient
 * being authored" context at a time. Edit mode hangs it directly off the target unit (a plain
 * 2-param setVariable - client-local, never networked, purely a UI convenience) so multiple units'
 * drafts never collide and it's naturally garbage-collected when the unit is deleted; this is
 * separate from AFCM_SIM_appliedInjuries (the real applied-state tracking
 * fnc_injuryAuthor_loadFromUnit.sqf falls back to when no draft exists yet for that unit).
 *
 * Deliberately independent of the afcm_sim_rememberLastInjuries CBA setting - that setting is the
 * separate, profileNamespace-backed "remember across missions/restarts" convenience written only on
 * a real Apply (fnc_injuryAuthor_onApply.sqf); this is a same-session "don't lose my in-progress
 * work just from backing out of the menu" safety net, on by default.
 *
 * Arguments:
 * 0: RscDisplayAFCM_SIM_InjuryAuthor <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

call afcm_sim_ui_fnc_injuryAuthor_commitActiveLimbForm;

private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];
private _katExtras = missionNamespace getVariable ["AFCM_SIM_UI_stagedKatExtras", [[0, 0, 0, 0, 0, 0], 0, 0, 0]];

if (missionNamespace getVariable ["AFCM_SIM_UI_authorNewPatient", true]) then {
    missionNamespace setVariable ["AFCM_SIM_UI_draftNewPatientInjuries", _injuries];
    missionNamespace setVariable ["AFCM_SIM_UI_draftNewPatientKatExtras", _katExtras];
    missionNamespace setVariable ["AFCM_SIM_UI_draftNewPatientValid", true];
} else {
    private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
    if !(isNull _targetUnit) then {
        _targetUnit setVariable ["AFCM_SIM_UI_draftInjuries", _injuries];
        _targetUnit setVariable ["AFCM_SIM_UI_draftKatExtras", _katExtras];
        _targetUnit setVariable ["AFCM_SIM_UI_hasDraft", true];
    };
};

private _handle = missionNamespace getVariable ["AFCM_SIM_UI_statePFH", -1];

if (_handle != -1) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    missionNamespace setVariable ["AFCM_SIM_UI_statePFH", -1];
};
