/*
 * Author: Tasman Dynamics
 * Registers a real CBA keybind (default Ctrl+Shift+M, rebindable in Configure > Controls > Addon
 * Bindings) that opens the MCI Creator (afcm_sim_ui_fnc_mciCreator_open) - the practical, in-game
 * way to reach it without needing the debug console. Runs at preInit, same as
 * fnc_settings_preInit.sqf - CBA's own recommendation for keybind registration too.
 * CBA_fnc_addKeybind itself no-ops on a headless dedicated server (`if (!hasInterface) exitWith
 * {};`, real source), so no extra guard is needed here.
 *
 * Real signature confirmed directly from CBA_A3 source (addons/keybinding/fnc_addKeybind.sqf):
 * [_addon, _action, _title, _downCode, _upCode, _defaultKeybind] call CBA_fnc_addKeybind, where
 * _defaultKeybind is [DIK, [shift, ctrl, alt]]. DIK code hardcoded as 50 (M) rather than
 * `#include "\a3\ui_f\hpp\defineDIKCodes.inc"` for the readable DIK_M constant - that header lives
 * in the real game data, not this project's own source tree, so HEMTT's own `hemtt check` can't
 * resolve it locally and fails the build; the raw scan code is real/stable regardless (standard
 * XT keyboard scan code table, same one DIK_* constants are just aliases for).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

["AFCM-Simulator", "OpenMciCreator", "Open MCI Creator", {
    call afcm_sim_ui_fnc_mciCreator_open;
}, {}, [50, [true, true, false]]] call CBA_fnc_addKeybind;
