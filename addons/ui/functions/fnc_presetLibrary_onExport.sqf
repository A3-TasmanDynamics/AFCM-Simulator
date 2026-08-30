/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the Preset Library's Export button (RscDisplayAFCM_SIM_PresetLibrary).
 * Serializes the selected preset (afcm_sim_scenario_fnc_exportPreset) into the shared text field
 * (idc 14) and copies it to the OS clipboard via the real `copyToClipboard` command, so it can be
 * pasted anywhere outside the game (Discord, a text file, back into another player's Import box).
 * The text field also displays it directly, in case clipboard access misbehaves for any reason -
 * select-all + Ctrl+C from the field itself always works as a fallback.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Export button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlExport"];

private _display = ctrlParent _ctrlExport;
private _index = lbCurSel (_display displayCtrl 10);
if (_index == -1) exitWith {};

private _id = (_display displayCtrl 10) lbData _index;
private _preset = [_id] call afcm_sim_scenario_fnc_findPreset;
if (_preset isEqualTo []) exitWith {};

private _exported = [_preset] call afcm_sim_scenario_fnc_exportPreset;

(_display displayCtrl 14) ctrlSetText _exported;
copyToClipboard _exported;
