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
// (DESIGN.md §5). Module function bodies are stubs for now: afcm_sim_spawner doesn't have real
// patient-spawning logic yet, so these log rather than pretend to work. The module/category
// config below follows the standard Module_F pattern (matches how vanilla and most community Zeus
// modules — e.g. ACE3's — are declared); worth a real in-Zeus test once spawner logic exists,
// since the exact function-triggering semantics for Zeus-placed modules aren't independently
// verified here.
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
