class CfgPatches
{
    class afcm_sim_spawner
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main", "afcm_sim_scenario"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Patient spawner (DESIGN.md §3/§5). Stretcher placement and the map tool are not yet implemented.
// NOTE: explicit `file=`, full absolute virtual path — see afcm_sim_main/config.cpp for why both
// the fnc_ filename AND the absolute-path form are required.
class CfgFunctions
{
    class afcm_sim_spawner
    {
        tag = "afcm_sim_spawner";
        class Functions
        {
            file = "\afcm_sim\addons\spawner\functions";
            class spawnPatient { file = "\afcm_sim\addons\spawner\functions\fnc_spawnPatient.sqf"; };
            class spawnRandomPatient { file = "\afcm_sim\addons\spawner\functions\fnc_spawnRandomPatient.sqf"; };
            class clearAllPatients { file = "\afcm_sim\addons\spawner\functions\fnc_clearAllPatients.sqf"; };
        };
    };
};
