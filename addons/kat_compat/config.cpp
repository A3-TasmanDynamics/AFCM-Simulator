class CfgPatches
{
    class afcm_sim_kat_compat
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "ace_medical_engine", "kat_main", "afcm_sim_main"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// requiredAddons now gates on "kat_main" for real — confirmed via KAT's actual repo
// (github.com/KAT-Advanced-Medical/KAM): HEMTT-built, bare addon folders (main, airway, breathing,
// surgery, ...) under a "kat" project prefix, so the real CfgPatches root is "kat_main" (matches
// the kat_breathing_fnc_handleBreathing / kat_surgery_fractures usage seen in a prior working
// script too). Depends on CBA_A3 3.16.0+ and ACE3 3.16.1+ per KAT's own README — see
// REFERENCES.md. This PBO now only loads if KAT is actually present, so it's safe to register as
// a real backend (previously deferred specifically because this class name wasn't confirmed).
//
// applyInjury/getState are now real (KAT_COMPAT.md §3 — KAT extends ACE3's own wound pipeline
// rather than replacing it, so afcm_sim_ace_compat's real ACE3 calls apply correctly here too).
// removeInjury is still a stub. NOTE: explicit `file=` per leaf class, full absolute virtual path —
// see afcm_sim_main/config.cpp for why both the fnc_ filename AND the absolute-path form are required.
class CfgFunctions
{
    class afcm_sim_kat
    {
        tag = "afcm_sim_kat";
        class Functions
        {
            file = "\afcm_sim\addons\kat_compat\functions";
            class applyInjury { file = "\afcm_sim\addons\kat_compat\functions\fnc_applyInjury.sqf"; };
            class removeInjury { file = "\afcm_sim\addons\kat_compat\functions\fnc_removeInjury.sqf"; };
            class getState { file = "\afcm_sim\addons\kat_compat\functions\fnc_getState.sqf"; };
            class reset { file = "\afcm_sim\addons\kat_compat\functions\fnc_reset.sqf"; };
            class setUnconscious { file = "\afcm_sim\addons\kat_compat\functions\fnc_setUnconscious.sqf"; };
            // Not part of the backend interface hashmap below - called directly by
            // afcm_sim_scenario_fnc_serverApplyKatFracture/serverApplyKatPneumothorax, since
            // fracture/pneumothorax have no equivalent in the backend-agnostic Injury object
            // (INJURY_CODES.md §6).
            class applyFracture { file = "\afcm_sim\addons\kat_compat\functions\fnc_applyFracture.sqf"; };
            class applyPneumothorax { file = "\afcm_sim\addons\kat_compat\functions\fnc_applyPneumothorax.sqf"; };
            class preInit { file = "\afcm_sim\addons\kat_compat\functions\fnc_preInit.sqf"; preInit = 1; };
        };
    };
};
