/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Preset Library's Export button. Serializes the selected MCI
 * preset (afcm_sim_scenario_fnc_exportMciPreset) into the shared text field and copies it to the
 * OS clipboard (real `copyToClipboard` command) - same pattern as
 * fnc_presetLibrary_onExport.sqf.
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
private _mciPreset = [_id] call afcm_sim_scenario_fnc_findMciPreset;
if (_mciPreset isEqualTo []) exitWith {};

private _exported = [_mciPreset] call afcm_sim_scenario_fnc_exportMciPreset;

(_display displayCtrl 14) ctrlSetText _exported;
copyToClipboard _exported;
