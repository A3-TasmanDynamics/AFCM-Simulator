class CfgPatches
{
    class afcm_sim_eden
    {
        units[] = {"AFCM_SIM_ModulePatientPlacement", "AFCM_SIM_ModuleMascalZone", "AFCM_SIM_ModuleMciSpawnerPlacement"};
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
            class module_mciSpawner { file = "\afcm_sim\addons\eden\functions\fnc_module_mciSpawner.sqf"; };
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

    // Shared "Casualty Type" attribute (clothing/appearance only, DESIGN.md §5) — a plain nested
    // class, not a Module_F itself, purely so both modules below can inherit the same four options
    // via `class Attributes: AFCM_SIM_CasualtyTypeAttributes { ... }` instead of repeating them.
    // Values must line up with the classname array in afcm_sim_spawner_fnc_spawnPatient
    // (C_man_1/B_Soldier_F/O_Soldier_F/I_Soldier_F, all real, base-game classnames) and with
    // afcm_sim_defaultCasualtyType's CBA setting (main/functions/fnc_settings_preInit.sqf) — keep
    // all three in sync if this list ever changes.
    // Shared attributes common to every AFCM spawn module (not just Casualty Type anymore, despite
    // the name kept for continuity - renaming would only churn the config, since no placed mission
    // actually references this intermediate class name, only the final resolved attribute list).
    class AFCM_SIM_CasualtyTypeAttributes
    {
        // scope=0 - this is a plain nested-class template for Attributes inheritance, never a
        // real placeable object, but without an explicit scope the engine still treats any direct
        // CfgVehicles member as a candidate vehicle/object and logs "No entry ...scope/model/..."
        // warnings for every standard vehicle property it doesn't have (real, confirmed RPT noise,
        // harmless but spammy). scope=0 is the standard fix.
        scope = 0;
        class AFCM_SIM_CasualtyType
        {
            displayName = "Casualty Type";
            property = "AFCM_SIM_casualtyType";
            control = "combo";
            defaultValue = "0";
            class Values
            {
                class Civilian { name = "Civilian"; value = 0; default = 1; };
                class MilitaryBlufor { name = "Military (BLUFOR)"; value = 1; };
                class MilitaryOpfor { name = "Military (OPFOR)"; value = 2; };
                class MilitaryIndependent { name = "Military (Independent)"; value = 3; };
            };
        };
        // Free-text Spawn Session name (DESIGN.md § Spawn Sessions), optional - blank means the
        // module function auto-generates a label as before. Real, confirmed control type/shape
        // from the official BI wiki (Eden Editor: Configuring Attributes[/: Controls]): `control =
        // "Edit"` is a single-line text input saving a String; `typeName = "STRING"` is required
        // for Edit controls specifically (defaults to something else otherwise) - this codebase's
        // existing combo attributes never needed it since NUMBER is the assumed default there.
        class AFCM_SIM_SessionName
        {
            displayName = "Session Name (optional)";
            property = "AFCM_SIM_sessionName";
            control = "Edit";
            defaultValue = "";
            typeName = "STRING";
        };
    };

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
        //
        // Casualty Type IS still an attribute here though - purely cosmetic (clothing/appearance),
        // not tied to the injury-randomization pipeline the Injury Level attribute controlled, so
        // it makes sense on a manually-treated single patient too.
        class Attributes: AFCM_SIM_CasualtyTypeAttributes {};
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

        // Patient count, injury level, casualty type. Values read back via
        // `_logic getVariable ["AFCM_SIM_patientCount"/"AFCM_SIM_injuryLevel"/
        // "AFCM_SIM_casualtyType", default]` in the module function once spawner logic exists to
        // actually place patients (DESIGN.md §8 open question #4 — realistic max simultaneous
        // patients still needs a real number; the option list below is a starting guess, not a
        // validated limit). Inherits AFCM_SIM_CasualtyType from AFCM_SIM_CasualtyTypeAttributes
        // above, plus its own two attributes.
        class Attributes: AFCM_SIM_CasualtyTypeAttributes
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

    // Design-time counterpart to Zeus's AFCM_SIM_ModuleMciSpawner (addons/zeus/config.cpp) - a
    // batch of patients all spawned with the exact same real Injury Preset (INJURY_CODES.md §4)
    // applied, distinct from AFCM_SIM_ModuleMascalZone above (randomized injury level, not a
    // specific preset). Preset is a static Attribute here, not a live dialog like Zeus's version -
    // see fnc_module_mciSpawner.sqf's comment for why (a design-time module can't reference a
    // specific player's own future profileNamespace user presets).
    class AFCM_SIM_ModuleMciSpawnerPlacement: Module_F
    {
        scope = 2;
        scopeCurator = 2;
        side = 7;
        displayName = "AFCM MCI Spawner";
        icon = "\afcm_sim\addons\eden\data\module_mascal.paa";
        category = "AFCM_SIM_Category";
        function = "afcm_sim_eden_fnc_module_mciSpawner";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 0;

        // Patient count, casualty type, preset. Preset Values are numeric indices into
        // afcm_sim_scenario_fnc_getBuiltinPresets's own array order (fnc_module_mciSpawner.sqf
        // reads it back the same way Casualty Type/Injury Level already do elsewhere in this
        // addon) - keep both in sync if the built-in preset list ever changes.
        class Attributes: AFCM_SIM_CasualtyTypeAttributes
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
            class AFCM_SIM_MciPreset
            {
                displayName = "Preset";
                property = "AFCM_SIM_mciPreset";
                control = "combo";
                defaultValue = "0";
                class Values
                {
                    class GswChest { name = "GSW — Chest"; value = 0; default = 1; };
                    class GswLimbTq { name = "GSW — Limb (Tourniquet Candidate)"; value = 1; };
                    class BlastCasualty { name = "Blast Casualty"; value = 2; };
                    class FragMultiple { name = "Frag Wounds (Multiple)"; value = 3; };
                    class MinorLaceration { name = "Training — Minor Laceration"; value = 4; };
                };
            };
        };
    };
};
