/*
 * Author: Tasman Dynamics
 * LBSelChanged handler for the MCI Preset Library's listbox. Enables Load/Delete/Export once a row
 * is selected - Delete stays disabled for built-in MCI presets (id prefix "builtin_"), which are
 * read-only (fnc_deleteUserMciPreset.sqf guards this too, not just the UI).
 *
 * Real LBSelChanged signature: _this = [_control, _selectedIndex].
 *
 * Arguments (from the LBSelChanged event, not called directly):
 * 0: Listbox <CONTROL>
 * 1: Selected index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlList", "_index"];

private _display = ctrlParent _ctrlList;
private _hasSelection = _index != -1;
private _isBuiltin = _hasSelection && {(_ctrlList lbData _index) find "builtin_" == 0};

(_display displayCtrl 11) ctrlEnable _hasSelection;
(_display displayCtrl 12) ctrlEnable (_hasSelection && !_isBuiltin);
(_display displayCtrl 13) ctrlEnable _hasSelection;
