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
//
// Second, bigger gotcha (found by diffing against KAT's real addons/zeus/config.cpp): Zeus does
// NOT use CfgVehicleClasses for module categorization at all — that's an Eden (2D editor) only
// mechanism. Zeus groups modules by CfgFactionClasses + a matching `side` on the module class
// itself. `side = 7` is the neutral "Logic" side, which shows up regardless of the mission's
// actual side setup (that's what KAT uses for its own always-visible "KAM" category).
//
// `AFCM_SIM_Category` (below) must use the exact same class name as the CfgFactionClasses entry
// declared in addons/eden/config.cpp — Arma merges same-named config classes across all loaded
// addons, so a shared name here is what puts every AFCM module (Zeus's + Eden's Zeus-placeable
// ones) under a single unified category instead of two separate ones both labelled the same thing.
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

class CfgFactionClasses
{
    class AFCM_SIM_Category
    {
        displayName = "AFCM Medical Simulator";
        priority = 2;
        side = 7;
    };
};

class CfgVehicles
{
    class Module_F;

    class AFCM_SIM_ModuleSpawnRandomPatient: Module_F
    {
        scope = 2;
        scopeCurator = 2;
        side = 7;
        displayName = "Spawn Patient";
        icon = "\afcm_sim\addons\zeus\data\module_patient.paa";
        category = "AFCM_SIM_Category";
        function = "afcm_sim_zeus_fnc_module_spawnRandomPatient";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 0;
    };
};
