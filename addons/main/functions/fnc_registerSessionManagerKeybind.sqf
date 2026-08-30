/*
 * Author: Tasman Dynamics
 * Registers a real CBA keybind (default Ctrl+Shift+O, rebindable in Configure > Controls > Addon
 * Bindings) that opens the Session Manager (afcm_sim_ui_fnc_sessionManager_open) - the practical,
 * in-game way to reach it without needing the debug console. Runs at preInit, same as
 * fnc_registerMciCreatorKeybind.sqf/fnc_settings_preInit.sqf - CBA's own recommendation for
 * keybind registration too. CBA_fnc_addKeybind itself no-ops on a headless dedicated server
 * (`if (!hasInterface) exitWith {};`, real source, confirmed when this same reasoning was checked
 * for the MCI Creator's own keybind), so no extra guard is needed here.
 *
 * DIK code hardcoded as 24 (O) rather than `#include "\a3\ui_f\hpp\defineDIKCodes.inc"` for the
 * readable DIK_O constant - that header lives in the real game data, not this project's own source
 * tree, so HEMTT's own `hemtt check` can't resolve it locally (confirmed the hard way on the MCI
 * Creator's own keybind file); the raw scan code is real/stable regardless (standard XT keyboard
 * scan code table, same one DIK_* constants are just aliases for - Q=16,W=17,E=18,R=19,T=20,Y=21,
 * U=22,I=23,O=24,P=25 on that table).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

["AFCM-Simulator", "OpenSessionManager", "Open Session Manager", {
    call afcm_sim_ui_fnc_sessionManager_open;
}, {}, [24, [true, true, false]]] call CBA_fnc_addKeybind;
