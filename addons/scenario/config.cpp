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
        };
    };
};
