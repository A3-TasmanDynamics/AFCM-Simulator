class CfgPatches
{
    class afcm_sim_zeus
    {
        units[] = {"AFCM_SIM_ModuleSpawnRandomPatient"};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main", "afcm_sim_scenario", "afcm_sim_spawner"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Zeus (curator) modules — the live, in-mission side of "Random Patient" / MASCAL placement
// (DESIGN.md §5), now calling real afcm_sim_spawner logic. `scopeCurator = 2;` (below) is required
// in addition to `scope = 2;` — confirmed via a real in-Zeus test that without it, the module
// compiles and registers fine but simply never appears in the Zeus curator browser at all (plain
// `scope=2` alone is not sufficient for Zeus specifically, unlike Eden).
class CfgFunctions
{
    class afcm_sim_zeus
    {
        tag = "afcm_sim_zeus";
        class Modules
        {
            file = "\afcm_sim\addons\zeus\functions";
            // Explicit `file=`, full absolute virtual path — see afcm_sim_main/config.cpp for why
            // both the fnc_ filename AND the absolute-path form are required.
            class module_spawnRandomPatient { file = "\afcm_sim\addons\zeus\functions\fnc_module_spawnRandomPatient.sqf"; };
        };
    };
};

class CfgVehicleClasses
{
    class AFCM_SIM_Zeus
    {
        displayName = "AFCM Medical Simulator";
    };
};

class CfgVehicles
{
    class Module_F;

    class AFCM_SIM_ModuleSpawnRandomPatient: Module_F
    {
        scope = 2;
        scopeCurator = 2;
        displayName = "Spawn Random Patient";
        icon = "\a3\ui_f\data\IGUI\Cfg\Cursors\iconCursorTarget_ca.paa";
        category = "AFCM_SIM_Zeus";
        function = "afcm_sim_zeus_fnc_module_spawnRandomPatient";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 0;
    };
};
