/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the MCI Creator's "Choose Location on Map" button. Opens the Map Picker
 * (RscDisplayAFCM_SIM_MapPicker) on top of this dialog - doesn't close the Creator, the two just
 * stack (same pattern as the injury editor's Save as Preset opening on top of it).
 *
 * Commits this dialog's own Radius field (idc 25) into AFCM_SIM_UI_mciRadius first, so if the
 * operator just edited it here before opening the map, the Map Picker's own Radius field/circle
 * preview picks up that fresh value instead of a stale one - fnc_mciCreator_refreshLocationStatus.sqf
 * re-syncs it back here the other way once Confirm is clicked.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Choose Location button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlBtn"];

private _display = ctrlParent _ctrlBtn;
AFCM_SIM_UI_mciRadius = 0 max (parseNumber (ctrlText (_display displayCtrl 25)));

createDialog "RscDisplayAFCM_SIM_MapPicker";
