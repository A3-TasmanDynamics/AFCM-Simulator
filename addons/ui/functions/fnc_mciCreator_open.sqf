/*
 * Author: Tasman Dynamics
 * Opens the MCI Creator (RscDisplayAFCM_SIM_MciCreator) - the real entry point for the whole
 * feature, callable directly (`call afcm_sim_ui_fnc_mciCreator_open;`) and bound to a real CBA
 * keybind (afcm_sim_fnc_registerMciCreatorKeybind, default Ctrl+Shift+M). Doesn't require a Zeus/
 * Eden module to be placed first - the Zeus MCI Spawner module (fnc_module_mciSpawner.sqf) is one
 * caller among several (CBA keybind, Interactive Terminal's own "Open MCI Creator" action), not a
 * prerequisite.
 *
 * Guards against the same real, confirmed class of bug fnc_injuryAuthor_open.sqf's own header
 * documents for that dialog: a synchronous `createDialog` while the SAME IDD is already open can
 * silently misbehave. Now closes any already-open instance first and defers a frame before actually
 * opening - same "close, defer, open" pattern (CBA_fnc_execNextFrame), newly reachable here now that
 * the Zeus MCI Spawner module can trigger an open on its own (a curator already mid-session in the
 * MCI Creator, via the keybind, placing a fresh module would otherwise hit exactly this).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Bool - result of createDialog (false, not yet meaningful, when a prior instance had to be closed
 * and this call deferred a frame first)
 *
 * Public: Yes
*/

// 25605 = IDD_AFCM_SIM_MCICREATOR (addons/ui/config.cpp) - hardcoded since #defines aren't
// available in SQF; keep in sync if that IDD ever changes.
if !(isNull (findDisplay 25605)) exitWith {
    closeDialog 0;
    [{ call afcm_sim_ui_fnc_mciCreator_open; }, []] call CBA_fnc_execNextFrame;
    false
};

createDialog "RscDisplayAFCM_SIM_MciCreator"
