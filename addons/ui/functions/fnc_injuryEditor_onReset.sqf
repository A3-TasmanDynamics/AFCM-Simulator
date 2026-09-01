/*
 * Author: Tasman Dynamics
 * ButtonClick handler for the injury editor's "Reset Limb" button (RscDisplayAFCM_SIM_InjuryEditor).
 * Purely local - clears the wound type/severity/bleeding fields, plus Fracture/Pneumothorax/Airway
 * if visible (KAT only), back to their defaults (same defaults fnc_injuryEditor_init.sqf sets on
 * open: Gunshot / Moderate / unchecked / None / None / None) so an instructor can reconsider what
 * to apply to this limb, without touching the patient's actual medical state at all.
 *
 * This is deliberately NOT a medical operation - ACE doesn't expose a real, public API to heal
 * just one body part (`ace_medical_fnc_fullHeal`'s own "Body Part" argument is documented
 * "(unused)" in ACE3's real source, and the per-limb damage model underneath
 * (`ace_medical_engine_fnc_damageBodyPart`, itself `Public: No`) tracks left/right arm/leg via
 * custom internal state, not simple settable native hitpoints - there's no supported, reliable way
 * to scope a real heal to one limb). The full-patient wipe that used to live on this button moved
 * to the limb-select ("main") screen's own Reset Patient button
 * (fnc_limbSelect_onResetPatient.sqf) instead, where it's no longer misleadingly scoped to a
 * single limb.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Reset Limb button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlReset"];

disableSerialization;
private _display = ctrlParent _ctrlReset;

(_display displayCtrl 11) lbSetCurSel 0;
(_display displayCtrl 12) lbSetCurSel 1;
(_display displayCtrl 13) cbSetChecked false;
(_display displayCtrl 18) lbSetCurSel 0;
(_display displayCtrl 19) lbSetCurSel 0;
(_display displayCtrl 23) lbSetCurSel 0;

diag_log text "[AFCM-Simulator][UI] Reset Limb clicked - injury editor form cleared to defaults.";
