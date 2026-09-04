/*
 * Author: Tasman Dynamics
 * Registers a real CBA keybind (default Ctrl+Shift+I, rebindable in Configure > Controls > Addon
 * Bindings) that opens the Injury Author dialog (afcm_sim_ui_fnc_injuryAuthor_open) with no target
 * unit - the "author a brand-new patient's injuries before it exists" entry point, reachable
 * without needing a patient already spawned or a module placed. Runs at preInit, same as
 * fnc_registerMciCreatorKeybind.sqf/fnc_registerSessionManagerKeybind.sqf - CBA's own
 * recommendation for keybind registration too. CBA_fnc_addKeybind itself no-ops on a headless
 * dedicated server (`if (!hasInterface) exitWith {};`, confirmed when this same reasoning was
 * checked for the other two keybinds here), so no extra guard is needed.
 *
 * DIK code hardcoded as 23 (I), same reasoning as fnc_registerSessionManagerKeybind.sqf's own
 * comment: the real \a3\ui_f\hpp\defineDIKCodes.inc header isn't in this project's own source tree,
 * so `hemtt check` can't resolve the readable DIK_I constant locally - the raw scan code is real/
 * stable regardless (standard XT keyboard scan code table: Q=16,W=17,E=18,R=19,T=20,Y=21,U=22,
 * I=23,O=24,P=25 - O and P already taken by the other two AFCM keybinds).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

["AFCM-Simulator", "OpenInjuryAuthor", "Open Injury Author (New Patient)", {
    call afcm_sim_ui_fnc_injuryAuthor_open;
}, {}, [23, [true, true, false]]] call CBA_fnc_addKeybind;
