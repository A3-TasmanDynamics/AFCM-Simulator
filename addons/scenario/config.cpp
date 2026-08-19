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

// Domain logic: injury model, preset library, randomization profiles (DESIGN.md §3/§4) — not yet
// implemented. Calls the backend interface (afcm_sim_fnc_backend_*, owned by afcm_sim_main) once
// built; never AFCM or ACE3 directly.
