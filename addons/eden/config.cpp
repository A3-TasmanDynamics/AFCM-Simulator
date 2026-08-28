class CfgPatches
{
    class afcm_sim_eden
    {
        units[] = {"AFCM_SIM_ModulePatientPlacement", "AFCM_SIM_ModuleMascalZone"};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main", "afcm_sim_scenario", "afcm_sim_spawner"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Eden (mission editor) modules — the design-time side of patient placement (DESIGN.md §5 "Map to
// Spawn Patients"), now calling real afcm_sim_spawner logic. `scopeCurator = 2;` is set here too
// even though these are Eden-placed, not Zeus-placed — confirmed via a real in-Zeus test that
// Zeus specifically requires it in addition to `scope = 2;` (plain scope=2 alone doesn't make a
// module appear in the Zeus curator browser at all), and setting it also lets these modules be
// placed via Zeus if a mission maker ever wants that, at no cost.
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
            class module_mascalZone { file = "\afcm_sim\addons\eden\functions\fnc_module_mascalZone.sqf"; };
        };
    };
};

// Two separate category systems, only one of which is shared with addons/zeus/config.cpp:
// CfgVehicleClasses is what the Eden (2D editor) "Add Object" browser groups by, and is local to
// this file since Zeus doesn't use it at all. CfgFactionClasses + a matching `side` on the module
// class is the mechanism Zeus actually uses (see addons/zeus/config.cpp for the full story) — its
// class name, `AFCM_SIM_Category`, MUST match the one declared there exactly, since Arma merges
// same-named config classes across addons and that's what puts every AFCM module (this file's
// Zeus-placeable ones plus zeus/config.cpp's own) under one unified Zeus category instead of two.
class CfgVehicleClasses
{
    class AFCM_SIM_Category
    {
        displayName = "AFCM Medical Simulator";
    };
};

class CfgFactionClasses
{
    class AFCM_SIM_Category
    {
        displayName = "AFCM Medical Simulator";
        priority = 2;
        side = 7;
    };
};

class CfgVehicles
{
    class Module_F;

    class AFCM_SIM_ModulePatientPlacement: Module_F
    {
        scope = 2;
        scopeCurator = 2;
        side = 7;
        displayName = "AFCM Patient";
        icon = "\afcm_sim\addons\eden\data\module_patient.paa";
        category = "AFCM_SIM_Category";
        function = "afcm_sim_eden_fnc_module_patientPlacement";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 0;

        // No Injury Level attribute anymore - this module now spawns a clean, unconscious patient
        // and relies on the "Edit Injuries" scroll action (added to every spawned patient,
        // afcm_sim_spawner_fnc_spawnPatient) for real injury selection, same as Zeus's Spawn
        // Patient module. AFCM_SIM_ModuleMascalZone below keeps its own Injury Level attribute -
        // that one's still a randomized batch-spawn tool.
    };

    // Design-time counterpart to "Map to Spawn Patients... MASCAL scenarios" (DESIGN.md §5) — a
    // placed area where multiple patients spawn on mission start, rather than one at a time.
    // Distinct from AFCM_SIM_ModulePatientPlacement (single patient) above.
    class AFCM_SIM_ModuleMascalZone: Module_F
    {
        scope = 2;
        scopeCurator = 2;
        side = 7;
        displayName = "AFCM MASCAL Zone";
        icon = "\afcm_sim\addons\eden\data\module_mascal.paa";
        category = "AFCM_SIM_Category";
        function = "afcm_sim_eden_fnc_module_mascalZone";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 0;

        // Patient count and injury level. Values read back via
        // `_logic getVariable ["AFCM_SIM_patientCount"/"AFCM_SIM_injuryLevel", default]` in the
        // module function once spawner logic exists to actually place patients (DESIGN.md §8 open
        // question #4 — realistic max simultaneous patients still needs a real number; the option
        // list below is a starting guess, not a validated limit).
        class Attributes
        {
            class AFCM_SIM_PatientCount
            {
                displayName = "Patient Count";
                property = "AFCM_SIM_patientCount";
                control = "combo";
                defaultValue = "4";
                class Values
                {
                    class Two { name = "2"; value = 2; };
                    class Four { name = "4"; value = 4; default = 1; };
                    class Six { name = "6"; value = 6; };
                    class Eight { name = "8"; value = 8; };
                    class Ten { name = "10"; value = 10; };
                };
            };
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
