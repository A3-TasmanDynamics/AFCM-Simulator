class CfgPatches
{
    class afcm_sim_ui
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

// Native-dialog component kit + event bus (DESIGN.md §2.4/§3) — not yet implemented. Scaffolded
// so the repo layout matches DESIGN.md §7; RscDisplay/RscControls dialogs land as their own
// focused pass once the backend plumbing (afcm_sim_scenario) is in place.
