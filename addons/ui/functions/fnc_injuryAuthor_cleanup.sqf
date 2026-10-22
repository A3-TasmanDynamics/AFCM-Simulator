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
 * Author-new-patient mode only now - a plain missionNamespace var
 * (AFCM_SIM_UI_draftNewPatientInjuries/KatExtras/Valid), since there's only ever one "new patient
 * being authored" context at a time, and no live unit exists yet for this to go stale against. Edit
 * mode USED TO hang an equivalent draft directly off the target unit - removed as a real, confirmed
 * bug (fnc_injuryAuthor_open.sqf's own header has the full report/explanation): this ran
 * unconditionally on every close regardless of whether Apply was ever used, so it permanently
 * shadowed live reload on every later open, even after the patient took further real damage.
 * Edit mode now always reloads fresh from the live unit instead
 * (fnc_injuryAuthor_loadFromUnit.sqf) - there's nothing left for this function to snapshot there.
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
};

private _handle = missionNamespace getVariable ["AFCM_SIM_UI_statePFH", -1];

if (_handle != -1) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    missionNamespace setVariable ["AFCM_SIM_UI_statePFH", -1];
};
