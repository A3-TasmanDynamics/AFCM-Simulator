class CfgPatches
{
    class afcm_sim_main
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// CfgMods (Workshop-facing metadata — name/picture/description) belongs here once there's real
// content for it; not added yet since there's nothing real to put in it.

// Backend interface + detection mechanism (DESIGN.md §2.5/§6). Lives here rather than in
// afcm_sim_scenario because it's foundational infra every other addon sits on top of — not
// scenario-specific domain logic. afcm_sim_scenario, afcm_sim_spawner, and both backend addons
// all requiredAddon afcm_sim_main to reach it.
//
// NOTE: every leaf class below sets an explicit `file=` pointing at its real fnc_*.sqf filename,
// as a full absolute virtual path (\afcm_sim\addons\main\..., matching $PBOPREFIX$) rather than a
// path relative to the addon folder — a path like "main\functions\fnc_x.sqf" looks plausible but
// does NOT resolve (confirmed by an actual in-game launch: "Script ... not found" even with the
// right filename). The engine's CfgFunctions default (with no override) derives fn_<ClassName>.sqf
// — NOT fnc_ — so without these overrides every function here silently fails to load at runtime
// despite compiling fine at build time; neither `hemtt build` nor `hemtt check` catch either of
// these two mistakes.
class CfgFunctions
{
    class afcm_sim
    {
        tag = "afcm_sim";
        class Backend
        {
            file = "\afcm_sim\addons\main\functions";
            class backend_registerBackend { file = "\afcm_sim\addons\main\functions\fnc_backend_registerBackend.sqf"; };
            class backend_selectBackend { file = "\afcm_sim\addons\main\functions\fnc_backend_selectBackend.sqf"; };
            class backend_applyInjury { file = "\afcm_sim\addons\main\functions\fnc_backend_applyInjury.sqf"; };
            class backend_removeInjury { file = "\afcm_sim\addons\main\functions\fnc_backend_removeInjury.sqf"; };
            class backend_getActive { file = "\afcm_sim\addons\main\functions\fnc_backend_getActive.sqf"; };
            class backend_getState { file = "\afcm_sim\addons\main\functions\fnc_backend_getState.sqf"; };
            class backend_reset { file = "\afcm_sim\addons\main\functions\fnc_backend_reset.sqf"; };
            // postInit, not preInit: the engine guarantees every addon's preInit (where backend
            // registration happens, see fnc_backend_registerBackend.sqf) finishes before ANY
            // addon's postInit runs — a native two-phase guarantee that doesn't need CBA's event
            // system at all. (Earlier attempt subscribed to a "CBA_addons_postInit" event via
            // CBA_fnc_addEventHandler; that event doesn't exist as a subscribable global broadcast
            // — CBA's own postInit is the same per-addon postInit=1 mechanism as this one.)
            class main_postInit { file = "\afcm_sim\addons\main\functions\fnc_main_postInit.sqf"; postInit = 1; };
            // preInit, not postInit: just subscribes to a CBA event (CBA_settingsInitialized) -
            // needs to be registered before that event can possibly fire, and doesn't depend on
            // backend registration/selection at all, so there's no reason to wait for postInit.
            class disableSpontaneousWakeup { file = "\afcm_sim\addons\main\functions\fnc_disableSpontaneousWakeup.sqf"; preInit = 1; };
        };
        class Settings
        {
            file = "\afcm_sim\addons\main\functions";
            // CBA Addon Options (DESIGN.md — user-configurable settings, "Configure > Addon
            // Options > AFCM Medical Simulator" in-game). preInit per CBA's own recommendation, so
            // settings are available in the Eden Editor too, not just in-game.
            class settings_preInit { file = "\afcm_sim\addons\main\functions\fnc_settings_preInit.sqf"; preInit = 1; };
            // Not yet wired into backend_registerBackend/backend_selectBackend — those are already
            // verified working in-game and left untouched to avoid reintroducing risk; available
            // for new call sites (zeus/eden/spawner) going forward.
            class debugLog { file = "\afcm_sim\addons\main\functions\fnc_debugLog.sqf"; };
        };
    };
};
