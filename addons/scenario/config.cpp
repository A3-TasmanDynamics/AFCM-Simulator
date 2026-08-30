class CfgPatches
{
    class afcm_sim_scenario
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Domain logic: injury model, preset library, randomization profiles (DESIGN.md §3/§4). Calls the
// backend interface (afcm_sim_fnc_backend_*, owned by afcm_sim_main) once it needs to apply
// anything; never AFCM or ACE3 directly. NOTE: explicit `file=`, full absolute virtual path — see
// afcm_sim_main/config.cpp for why both the fnc_ filename AND the absolute-path form are required.
class CfgFunctions
{
    class afcm_sim_scenario
    {
        tag = "afcm_sim_scenario";
        class Functions
        {
            file = "\afcm_sim\addons\scenario\functions";
            class randomizeInjuries { file = "\afcm_sim\addons\scenario\functions\fnc_randomizeInjuries.sqf"; };
            class serverApplyInjury { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyInjury.sqf"; };
            class serverReset { file = "\afcm_sim\addons\scenario\functions\fnc_serverReset.sqf"; };
            class serverApplyKatFracture { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyKatFracture.sqf"; };
            class serverApplyKatPneumothorax { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyKatPneumothorax.sqf"; };
        };
        // Injury Presets (DESIGN.md §4.3/§ Injury Presets) - built-in library + a per-player
        // profileNamespace-backed user library, plain-Array export/import, and the server-side
        // batch-apply handler. Separate class purely for readability; same tag/file path.
        class Presets
        {
            file = "\afcm_sim\addons\scenario\functions";
            class getBuiltinPresets { file = "\afcm_sim\addons\scenario\functions\fnc_getBuiltinPresets.sqf"; };
            class getUserPresets { file = "\afcm_sim\addons\scenario\functions\fnc_getUserPresets.sqf"; };
            class saveUserPreset { file = "\afcm_sim\addons\scenario\functions\fnc_saveUserPreset.sqf"; };
            class deleteUserPreset { file = "\afcm_sim\addons\scenario\functions\fnc_deleteUserPreset.sqf"; };
            class exportPreset { file = "\afcm_sim\addons\scenario\functions\fnc_exportPreset.sqf"; };
            class importPreset { file = "\afcm_sim\addons\scenario\functions\fnc_importPreset.sqf"; };
            class serverApplyPreset { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyPreset.sqf"; };
            class findPreset { file = "\afcm_sim\addons\scenario\functions\fnc_findPreset.sqf"; };
        };
    };
};
