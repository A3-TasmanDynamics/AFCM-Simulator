class CfgPatches
{
    class afcm_sim_eden
    {
        units[] = {"AFCM_SIM_ModulePatientPlacement"};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main", "afcm_sim_scenario", "afcm_sim_spawner"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Eden (mission editor) module — the design-time side of patient placement (DESIGN.md §5 "Map to
// Spawn Patients"): a mission maker places this, picks an injury level from its Attributes panel,
// and it should spawn/configure that patient on mission start. Module_F + scope=2 is enough for
// vanilla/ACE3-style modules to appear in Eden's Systems/Modules browser without an explicit
// is3DEN flag; worth confirming placement/visibility in the actual editor once this is built,
// since that isn't independently verified here.
class CfgFunctions
{
    class afcm_sim_eden
    {
        tag = "afcm_sim_eden";
        class Modules
        {
            file = "\afcm_sim\addons\eden\functions";
            // Explicit `file=`, full absolute virtual path — see afcm_sim_main/config.cpp for why
            // both the fnc_ filename AND the absolute-path form are required.
            class module_patientPlacement { file = "\afcm_sim\addons\eden\functions\fnc_module_patientPlacement.sqf"; };
        };
    };
};

class CfgVehicleClasses
{
    class AFCM_SIM_Eden
    {
        displayName = "AFCM Medical Simulator";
    };
};

class CfgVehicles
{
    class Module_F;

    class AFCM_SIM_ModulePatientPlacement: Module_F
    {
        scope = 2;
        displayName = "AFCM Patient";
        icon = "\a3\ui_f\data\IGUI\Cfg\Cursors\iconCursorTarget_ca.paa";
        category = "AFCM_SIM_Eden";
        function = "afcm_sim_eden_fnc_module_patientPlacement";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 0;

        // Injury-level attribute (DESIGN.md §4.4). Gameplay-authoring difficulty scale — NOT a
        // real triage category, see TERMINOLOGY.md §2/§10. Value read back via
        // `_logic getVariable ["AFCM_SIM_injuryLevel", 0]` in the module function once it's real.
        class Attributes
        {
            class AFCM_SIM_InjuryLevel
            {
                displayName = "Injury Level";
                property = "AFCM_SIM_injuryLevel";
                control = "combo";
                defaultValue = "0";
                class Values
                {
                    class Easy { name = "Easy"; value = 0; default = 1; };
                    class Medium { name = "Medium"; value = 1; };
                    class Hard { name = "Hard"; value = 2; };
                    class Extreme { name = "Extreme"; value = 3; };
                    class Fucked { name = "F*CKED!"; value = 4; };
                };
            };
        };
    };
};
