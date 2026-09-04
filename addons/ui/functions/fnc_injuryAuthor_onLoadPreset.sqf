/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Injury Author dialog's Load Preset button. Sets
 * AFCM_SIM_UI_targetStaging (a new third mode fnc_presetLibrary_onApply.sqf checks before its
 * existing plural/singular branches), clears AFCM_SIM_UI_targetUnits (guards against a stale MCI
 * batch leaking in, same reasoning fnc_limbSelect_onOpenPresets.sqf already had), closes this
 * dialog, and reopens the Preset Library - same "close, defer, open" pattern (CBA_fnc_execNextFrame
 * - synchronous createDialog-after-closeDialog-same-frame can silently fail) that dialog's other
 * openers already use.
 *
 * fnc_injuryAuthor_loadPresetArrays.sqf is what actually loads the selected preset back into this
 * dialog's staged arrays and reopens it, once the Preset Library's own Apply is clicked.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Load Preset button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlLoad"];

missionNamespace setVariable ["AFCM_SIM_UI_targetStaging", true];
missionNamespace setVariable ["AFCM_SIM_UI_targetUnits", []];

closeDialog 0;

[{
    createDialog "RscDisplayAFCM_SIM_PresetLibrary";
}, []] call CBA_fnc_execNextFrame;
