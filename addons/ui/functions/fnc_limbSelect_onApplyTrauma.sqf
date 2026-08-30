/*
 * Author: Tasman Dynamics
 * Button handler for the limb-selection dialog's "Apply Trauma to Selected Limb(s)" button
 * (RscDisplayAFCM_SIM_LimbSelect). Stays disabled until at least one limb is toggled
 * (fnc_limbSelect_refreshButtons.sqf), so the empty-selection guard here is defensive, not the
 * primary safeguard. Closes this dialog and opens the injury editor for the WHOLE selection at
 * once (AFCM_SIM_UI_targetLimbs, plural) - one wound configuration gets applied to every selected
 * limb in a single Apply, rather than repeating the whole flow per limb.
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

if (AFCM_SIM_UI_selectedLimbs isEqualTo []) exitWith {};

["limb.selected", [AFCM_SIM_UI_selectedLimbs]] call afcm_sim_ui_fnc_publish;

private _targetUnit = missionNamespace getVariable ["AFCM_SIM_UI_targetUnit", objNull];
private _limbs = +AFCM_SIM_UI_selectedLimbs;

closeDialog 0;

[{
    params ["_targetUnit", "_limbs"];
    [_targetUnit, _limbs] call afcm_sim_ui_fnc_injuryEditor_open;
}, [_targetUnit, _limbs]] call CBA_fnc_execNextFrame;
