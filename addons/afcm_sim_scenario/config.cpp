class CfgPatches
{
    class afcm_sim_scenario
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

// Backend-agnostic interface (DESIGN.md §2.5): afcm_sim_ui/afcm_sim_spawner and both backend
// addons only ever call afcm_sim_fnc_backend_* — never AFCM or ACE3 directly.
class CfgFunctions
{
    class afcm_sim
    {
        tag = "afcm_sim";
        class Backend
        {
            file = "afcm_sim_scenario\functions";
            class backend_registerBackend {};
            class backend_selectBackend {};
            class backend_applyInjury {};
            class backend_removeInjury {};
            class backend_getActive {};
            class scenario_preInit { preInit = 1; };
        };
    };
};
