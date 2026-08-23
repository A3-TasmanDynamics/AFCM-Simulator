/*
 * Author: Tasman Dynamics
 * Opens the limb-selection dialog (DESIGN.md §5 "Selectable Body Limbs"). Selecting a limb
 * publishes "limb.selected" on the UI event bus, closes this dialog, then opens the injury editor
 * (fnc_injuryEditor_open.sqf) for the same target unit + limb — this dialog never calls
 * afcm_sim_scenario directly (DESIGN.md §3), only afcm_sim_ui's own next dialog.
 *
 * _targetUnit is stashed in a plain (client-local, unsynced) missionNamespace variable rather than
 * threaded through dialog params, since RscDisplay dialogs don't take arguments — every downstream
 * step in this flow (onLimbClick, the injury editor) reads it back from there.
 *
 * Arguments:
 * 0: Target unit <OBJECT> - the patient this injury editor session is for
 *
 * Return Value:
 * Bool - result of createDialog
 *
 * Public: Yes
*/

params ["_targetUnit"];

missionNamespace setVariable ["AFCM_SIM_UI_targetUnit", _targetUnit];

createDialog "RscDisplayAFCM_SIM_LimbSelect"
