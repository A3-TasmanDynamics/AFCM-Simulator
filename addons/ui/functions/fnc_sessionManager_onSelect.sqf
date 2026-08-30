/*
 * Author: Tasman Dynamics
 * LBSelChanged handler for the Session Manager's listbox. Enables Delete Selected Session once a
 * row is actually selected.
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

((ctrlParent _ctrlList) displayCtrl 11) ctrlEnable (_index != -1);
