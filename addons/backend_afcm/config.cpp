class CfgPatches
{
    class afcm_sim_backend_afcm
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_main", "afcm_sim_main"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Deferred to v1.x per DESIGN.md §9 — lands once AFCM's PatientState-mutation API (§8 open
// question #2) is stable enough to build against. No functions implemented yet; this PBO exists
// only so the repo layout matches DESIGN.md §7 and requiredAddons is already correctly gated on
// afcm_main for the moment it's needed. Only loads if AFCM is present — same soft-dependency
// mechanism as afcm_sim_backend_ace (DESIGN.md §2.5).
