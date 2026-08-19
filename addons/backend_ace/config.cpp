class CfgPatches
{
    class afcm_sim_backend_ace
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "ace_medical_engine", "afcm_sim_scenario"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Only loads if ACE3 (ace_medical_engine) is present — this is what makes AFCM a soft dependency
// rather than a hard one (DESIGN.md §2.5). requiredAddons also includes afcm_sim_scenario so this
// PBO is guaranteed to load after it, meaning afcm_sim_fnc_backend_registerBackend already exists
// by the time this addon's own preInit calls it.
class CfgFunctions
{
    class afcm_sim_ace
    {
        tag = "afcm_sim_ace";
        class Functions
        {
            file = "backend_ace\functions";
            class applyInjury {};
            class removeInjury {};
            class preInit { preInit = 1; };
        };
    };
};
