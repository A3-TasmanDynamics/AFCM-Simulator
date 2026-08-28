/*
 * Author: Tasman Dynamics
 * The real root cause of patients "healing themselves": ACE3's `medical_statemachine` addon (a
 * different component than `medical_ai`, which was already ruled out - see KAT_COMPAT.md §3/commit
 * history) has a real "spontaneous wake up from unconsciousness" mechanic
 * (fnc_handleStateUnconscious.sqf) - once a unit's vitals stabilize, there's a random chance every
 * check interval (real setting `ace_medical_spontaneousWakeUpChance`, default 0.1) that it wakes up
 * on its own, with no treatment at all. Once awake, `ace_medical_ai`'s unconsciousness guard on
 * self-treatment no longer applies, and since `ace_medical_ai_requireItems` also defaults to
 * disabled, the now-awake AI patient can "bandage"/"use morphine" on itself for free with an empty
 * inventory - which is exactly what showed up in a real Activity Log.
 *
 * Sets the real, live-adjustable (no mission-restart needed, unlike ace_medical_ai_enabledFor)
 * ACE setting to 0, server-authoritative. This affects every unit mission-wide, not just AFCM
 * patients - deliberately: AFCM-Simulator is a realistic medical-training tool, and "casualties
 * spontaneously self-stabilize with zero treatment" runs directly against that purpose for any
 * unit in the mission, not just ones this mod spawned. There's no per-unit override in ACE's real
 * source to scope this more narrowly (confirmed - same conclusion as ruling out medical_ai).
 *
 * Waits for CBA_settingsInitialized (same real event ACE's own medical_ai addon waits for) before
 * setting anything, to avoid a race with CBA's settings system not being ready yet.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

["CBA_settingsInitialized", {
    if (isServer) then {
        ["ace_medical_spontaneousWakeUpChance", 0, true, "server"] call CBA_settings_fnc_set;
        diag_log text "[AFCM-Simulator] Set ace_medical_spontaneousWakeUpChance to 0 (server) - prevents unconscious patients waking/self-treating without real treatment.";
    };
}] call CBA_fnc_addEventHandler;
