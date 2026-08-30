/*
 * Author: Tasman Dynamics
 * Button handler for the limb-selection dialog's Presets button (RscDisplayAFCM_SIM_LimbSelect).
 * Closes this dialog and opens the Preset Library (RscDisplayAFCM_SIM_PresetLibrary) for the same
 * target unit (AFCM_SIM_UI_targetUnit, already stashed by fnc_limbSelect_open.sqf - presets apply
 * to the whole patient, not a specific limb, so nothing further needs stashing here).
 *
 * Clears AFCM_SIM_UI_targetUnits (plural) first - single-unit mode always wins here. That variable
 * is only ever set by the "Assign MCI Preset" batch action (fnc_addMciPresetAction.sqf), and must
 * not leak into a normal single-patient Presets click from a previous, unrelated MCI batch.
 *
 * Deferred via CBA_fnc_execNextFrame, same reasoning as fnc_injuryEditor_onBack.sqf - opening a
 * dialog synchronously in the same frame a prior closeDialog ran in can silently fail.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

missionNamespace setVariable ["AFCM_SIM_UI_targetUnits", []];

closeDialog 0;

[{
    createDialog "RscDisplayAFCM_SIM_PresetLibrary";
}, []] call CBA_fnc_execNextFrame;
