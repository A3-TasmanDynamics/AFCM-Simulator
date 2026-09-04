/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's Save as Preset button. Commits the active
 * limb's form, then stashes the whole staged injuries array as a preset-in-progress
 * (AFCM_SIM_UI_pendingPresetInjuries - same variable/shape fnc_injuryEditor_onSavePreset.sqf used)
 * before opening RscDisplayAFCM_SIM_PresetSave on top of this dialog to name and save it.
 *
 * Deliberately excludes KAT extras/cardiac state from the saved preset, matching the exact
 * behaviour/reasoning the old InjuryEditor's own Save as Preset already had - the Preset schema
 * (DESIGN.md §4.3) only holds real Injury-shaped entries, no slot for whole-region/whole-patient
 * state. A patient that needs KAT extras preserved is still only reusable via Export (this dialog's
 * own Export button, or a live patient's Export Patient State action), not Save as Preset.
 *
 * Doesn't close this dialog - Save as Preset never touches a live unit, so there's no reason to
 * lose the staging session; the two dialogs simply stack.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Save as Preset button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlSave"];

call afcm_sim_ui_fnc_injuryAuthor_commitActiveLimbForm;

private _injuries = missionNamespace getVariable ["AFCM_SIM_UI_stagedInjuries", []];

if (_injuries isEqualTo []) exitWith {
    ["Injury Author", "Nothing staged to save as a preset yet."] call afcm_sim_ui_fnc_showToast;
};

missionNamespace setVariable ["AFCM_SIM_UI_pendingPresetInjuries", _injuries];

[{
    createDialog "RscDisplayAFCM_SIM_PresetSave";
}, []] call CBA_fnc_execNextFrame;
