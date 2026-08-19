class CfgPatches
{
    class afcm_sim_acm_compat
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

// Deferred, config-only stub — same reasoning as afcm_sim_kat_compat. requiredAddons is currently
// identical to afcm_sim_ace_compat (ACE3 only) because ACM (Advanced Combat Medicine)'s actual
// CfgPatches class name isn't confirmed yet. Deliberately NOT registering as a backend yet (no
// functions/, no preInit) — doing so now would make this PBO load and win priority over
// ace_compat whenever ACE3 alone is present, even without ACM actually installed, which would be
// wrong. Once the real ACM requiredAddon is confirmed, add it here, then build the applyInjury/
// removeInjury implementation and register at a higher priority than afcm_sim_ace_compat.
//
// KAT and ACM are both alternative overhauls of ACE3 medical and are not expected to run
// together in practice — if both were somehow present and both fully implemented, priority
// selection between them would be arbitrary (DESIGN.md open question, not yet resolved).
