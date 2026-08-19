class CfgPatches
{
    class afcm_sim_ace_compat
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "ace_medical_engine", "afcm_sim_main"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Baseline ACE3 compat backend (vanilla ace_medical_engine, no KAT/ACM). Only loads if ACE3 is
// present — this is what makes AFCM a soft dependency rather than a hard one (DESIGN.md §2.5).
// requiredAddons also includes afcm_sim_main so this PBO is guaranteed to load after it, meaning
// afcm_sim_fnc_backend_registerBackend already exists by the time this addon's own preInit calls
// it. Registers at priority 10 — lowest of the compat/native backends, since afcm_compat (native
// AFCM) and, once real KAT/ACM detection lands, kat_compat/acm_compat should all outrank plain
// vanilla-ACE3 behaviour when their target mod is actually present (DESIGN.md §2.5).
class CfgFunctions
{
    class afcm_sim_ace
    {
        tag = "afcm_sim_ace";
        class Functions
        {
            file = "ace_compat\functions";
            class applyInjury {};
            class removeInjury {};
            class preInit { preInit = 1; };
        };
    };
};
