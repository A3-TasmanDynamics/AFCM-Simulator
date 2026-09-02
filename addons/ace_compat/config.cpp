class CfgPatches
{
    class afcm_sim_ace_compat
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "ace_medical_engine", "afcm_sim_main"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Baseline ACE3 compat backend (vanilla ace_medical_engine, no KAT/ACM). Only loads if ACE3 is
// present — this is what makes AFCM a soft dependency rather than a hard one (DESIGN.md §2.5).
// requiredAddons also includes afcm_sim_main so this PBO is guaranteed to load after it, meaning
// afcm_sim_fnc_backend_registerBackend already exists by the time this addon's own preInit calls
// it. Registers at priority 10 — lowest of the compat/native backends, since afcm_compat (native
// AFCM) and, once real KAT/ACM detection lands, kat_compat/acm_compat should all outrank plain
// vanilla-ACE3 behaviour when their target mod is actually present (DESIGN.md §2.5).
// NOTE: explicit `file=` per leaf class, as a full absolute virtual path (matching $PBOPREFIX$) —
// see afcm_sim_main/config.cpp for why both the fnc_ filename AND the absolute-path form are
// required (neither `hemtt build` nor `hemtt check` catch either mistake; only an actual in-game
// launch does).
class CfgFunctions
{
    class afcm_sim_ace
    {
        tag = "afcm_sim_ace";
        class Functions
        {
            file = "\afcm_sim\addons\ace_compat\functions";
            class applyInjury { file = "\afcm_sim\addons\ace_compat\functions\fnc_applyInjury.sqf"; };
            class removeInjury { file = "\afcm_sim\addons\ace_compat\functions\fnc_removeInjury.sqf"; };
            class getState { file = "\afcm_sim\addons\ace_compat\functions\fnc_getState.sqf"; };
            class reset { file = "\afcm_sim\addons\ace_compat\functions\fnc_reset.sqf"; };
            class setUnconscious { file = "\afcm_sim\addons\ace_compat\functions\fnc_setUnconscious.sqf"; };
            // Not part of the backend interface hashmap below - called directly by
            // afcm_sim_scenario_fnc_serverApplyCardiacState, same pattern as kat_compat's
            // applyFracture/applyPneumothorax/applyAirway - a whole-patient vitals state has no
            // place in the backend-agnostic Injury object. Genuinely ACE-native (not KAT-specific),
            // so it lives here too, not just in kat_compat.
            class applyCardiacState { file = "\afcm_sim\addons\ace_compat\functions\fnc_applyCardiacState.sqf"; };
            class preInit { file = "\afcm_sim\addons\ace_compat\functions\fnc_preInit.sqf"; preInit = 1; };
        };
    };
};
