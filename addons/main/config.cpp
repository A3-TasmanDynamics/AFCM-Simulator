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
class CfgFunctions
{
    class afcm_sim
    {
        tag = "afcm_sim";
        class Backend
        {
            file = "main\functions";
            class backend_registerBackend {};
            class backend_selectBackend {};
            class backend_applyInjury {};
            class backend_removeInjury {};
            class backend_getActive {};
            class main_preInit { preInit = 1; };
        };
    };
};
