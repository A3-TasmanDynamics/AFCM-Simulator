class CfgPatches
{
    class afcm_sim_zeus
    {
        units[] = {"AFCM_SIM_ModuleSpawnRandomPatient", "AFCM_SIM_ModuleMciSpawner", "AFCM_SIM_ModuleEditInjuries"};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main", "afcm_sim_scenario", "afcm_sim_spawner"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Zeus (curator) modules — the live, in-mission side of "Random Patient" / MASCAL placement
// (DESIGN.md §5), now calling real afcm_sim_spawner logic. `scopeCurator = 2;` (below) is required
// in addition to `scope`, confirmed via a real in-Zeus test that without it, the module compiles
// and registers fine but simply never appears in the Zeus curator browser at all (plain `scope=2`
// alone is not sufficient for Zeus specifically, unlike Eden). `scope` itself is now set to `0`,
// not `2`, on every module below — deliberately keeping these OUT of the Eden 2D-editor module
// list, since Eden already has its own design-time counterparts (addons/eden/config.cpp: AFCM
// Patient, MCI Spawner) and showing both sets in Eden just duplicated/confused the module browser.
// Confirmed this doesn't affect Zeus visibility at all, since `scopeCurator` is explicitly defined
// here (see the BI wiki: scopeCurator only falls back to `scope` when left undefined).
//
// Second, bigger gotcha (found by diffing against KAT's real addons/zeus/config.cpp): Zeus does
// NOT use CfgVehicleClasses for module categorization at all — that's an Eden (2D editor) only
// mechanism. Zeus groups modules by CfgFactionClasses + a matching `side` on the module class
// itself. `side = 7` is the neutral "Logic" side, which shows up regardless of the mission's
// actual side setup (that's what KAT uses for its own always-visible "KAM" category).
//
// `AFCM_SIM_Category` (below) must use the exact same class name as the CfgFactionClasses entry
// declared in addons/eden/config.cpp — Arma merges same-named config classes across all loaded
// addons, so a shared name here is what puts every AFCM module (Zeus's + Eden's Zeus-placeable
// ones) under a single unified category instead of two separate ones both labelled the same thing.
class CfgFunctions
{
    class afcm_sim_zeus
    {
        tag = "afcm_sim_zeus";
        class Modules
        {
            file = "\afcm_sim\addons\zeus\functions";
            // Explicit `file=`, full absolute virtual path — see afcm_sim_main/config.cpp for why
            // both the fnc_ filename AND the absolute-path form are required.
            class module_spawnRandomPatient { file = "\afcm_sim\addons\zeus\functions\fnc_module_spawnRandomPatient.sqf"; };
            class module_mciSpawner { file = "\afcm_sim\addons\zeus\functions\fnc_module_mciSpawner.sqf"; };
            class module_editInjuries { file = "\afcm_sim\addons\zeus\functions\fnc_module_editInjuries.sqf"; };
        };
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

    // Same shared "Casualty Type" attribute as addons/eden/config.cpp (clothing/appearance only,
    // DESIGN.md §5) - duplicated here rather than shared across the two addons since each is its
    // own PBO/CfgVehicles block. Values must line up with the classname array in
    // afcm_sim_spawner_fnc_spawnPatient and afcm_sim_defaultCasualtyType's CBA setting - keep all
    // three in sync if this list ever changes.
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

    class AFCM_SIM_ModuleSpawnRandomPatient: Module_F
    {
        scope = 0;
        scopeCurator = 2;
        side = 7;
        displayName = "Spawn Patient";
        icon = "\afcm_sim\addons\zeus\data\module_patient.paa";
        category = "AFCM_SIM_Category";
        function = "afcm_sim_zeus_fnc_module_spawnRandomPatient";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 0;

        // Casualty Type attribute, same as Eden's AFCM_SIM_ModulePatientPlacement - double-clicking
        // a placed Zeus module opens the same Attributes dialog Eden uses (Module_F is shared
        // infrastructure between the two), so this works identically in-Zeus.
        class Attributes: AFCM_SIM_CasualtyTypeAttributes {};
    };

    // Live, Zeus-side counterpart to AFCM_SIM_ModuleMciSpawnerPlacement (addons/eden/config.cpp) -
    // "select a place on the map" is placing this module; "select a preset" happens right after,
    // via the "Assign MCI Preset" scroll action added to the spawned batch
    // (afcm_sim_ui_fnc_addMciPresetAction) rather than a static Attribute here, since Zeus placement
    // is a live, interactive moment that can reach the full real-time preset library (built-in +
    // the placing operator's own saved presets) - not just the 5 built-in ones Eden's design-time
    // version is limited to.
    class AFCM_SIM_ModuleMciSpawner: Module_F
    {
        scope = 0;
        scopeCurator = 2;
        side = 7;
        displayName = "MCI Spawner";
        icon = "\afcm_sim\addons\zeus\data\module_patient.paa";
        category = "AFCM_SIM_Category";
        function = "afcm_sim_zeus_fnc_module_mciSpawner";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 0;

        // Patient count + casualty type. No Preset attribute here - see the class comment above.
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
        };
    };

    // Drag this module directly onto any unit in the Zeus interface to open the Injury Editor for
    // it immediately - a faster alternative to scrolling to "Edit Injuries" on units that already
    // have that addAction (AFCM-spawned patients), and the only way to reach it on a unit that
    // doesn't (any other placed/spawned unit - the scroll action is only ever added by
    // afcm_sim_spawner_fnc_spawnPatient).
    //
    // Real, confirmed "drop directly onto a unit" pattern, grounded in ACE3's own Zeus module
    // source (acemod/ACE3, addons/zeus/CfgVehicles.hpp + fnc_moduleHeal.sqf - same idea as ACE3's
    // own "Heal" module): curatorCanAttach = 1 lets the module be dropped straight onto a unit
    // instead of needing a placement position of its own; fnc_module_editInjuries.sqf reads the
    // target back via `attachedTo _logic`, not the `_units` (synced units) param.
    class AFCM_SIM_ModuleEditInjuries: Module_F
    {
        scope = 0;
        scopeCurator = 2;
        side = 7;
        displayName = "Edit Injuries";
        icon = "\afcm_sim\addons\zeus\data\module_patient.paa";
        category = "AFCM_SIM_Category";
        function = "afcm_sim_zeus_fnc_module_editInjuries";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 1;
    };
};
