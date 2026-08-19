class CfgPatches
{
    class afcm_sim_kat_compat
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

// Deferred, config-only stub — same reasoning as afcm_sim_afcm_compat. requiredAddons is
// currently identical to afcm_sim_ace_compat (ACE3 only) because KAT - Advanced Medical's actual
// CfgPatches class name isn't confirmed yet (DESIGN.md §8 open question #1: "KAT internals").
// Deliberately NOT registering as a backend yet (no functions/, no preInit) — doing so now would
// make this PBO load and win priority over ace_compat whenever ACE3 alone is present, even
// without KAT actually installed, which would be wrong. Once the real KAT requiredAddon is
// confirmed, add it here, then build the applyInjury/removeInjury implementation and register at
// a higher priority than afcm_sim_ace_compat (KAT's model should outrank vanilla ACE3 when KAT is
// actually present).
