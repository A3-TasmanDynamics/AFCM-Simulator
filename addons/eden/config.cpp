class CfgPatches
{
    class afcm_sim_eden
    {
        units[] = {"AFCM_SIM_ModulePatientPlacement", "AFCM_SIM_ModuleInteractiveTerminal"};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main", "afcm_sim_scenario", "afcm_sim_spawner"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Eden (mission editor) modules — the design-time side of patient placement (DESIGN.md §5 "Map to
// Spawn Patients"), now calling real afcm_sim_spawner logic. Trimmed to just these two on request -
// AFCM MASCAL Zone, AFCM MCI Spawner (Eden), and Medical Tent were removed (their function files
// deleted, not just hidden) since only AFCM Patient and Interactive Terminal were still wanted;
// Zeus keeps its own MASCAL/MCI Spawner equivalents (addons/zeus/config.cpp), the MCI Creator UI
// still covers ad-hoc batch spawning, but Medical Tent has NO other entry point left anywhere in
// the mod now that its one Eden module is gone (see fnc_registerMedicalTent.sqf/
// fnc_startMedicalTentMonitor.sqf, still real code, just currently unreachable).
//
// `scope = 2;` makes both modules below placeable in Eden. `scopeCurator` differs per module:
// AFCM_SIM_ModulePatientPlacement is `0;` (hidden from the Zeus curator browser - Zeus already has
// its own live "Spawn Patient" doing the same job, so showing both there just duplicated/confused
// the module list); AFCM_SIM_ModuleInteractiveTerminal stays `2;` since it has no Zeus-side
// duplicate and specifically NEEDS Zeus visibility for its `curatorCanAttach = 1`
// drag-directly-onto-an-object mechanic to be reachable at all.
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
            class module_interactiveTerminal { file = "\afcm_sim\addons\eden\functions\fnc_module_interactiveTerminal.sqf"; };
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
        scopeCurator = 0;
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
        // by default and relies on the "Edit Injuries" scroll action (added to every spawned
        // patient, afcm_sim_spawner_fnc_spawnPatient) for real injury selection, same as Zeus's
        // Spawn Patient module - UNLESS the Injury Preset Import attribute below is filled in, in
        // which case the patient spawns pre-configured with those exact injuries instead.
        //
        // Casualty Type IS still an attribute here though - purely cosmetic (clothing/appearance),
        // not tied to the injury-randomization pipeline the old Injury Level attribute controlled,
        // so it makes sense on a manually-treated single patient too.
        //
        // Two more attributes, both read back by fnc_module_patientPlacement.sqf:
        //  - AFCM_SIM_InjuryPresetImport: paste an exported Injury Preset or Patient State string
        //    here to spawn this patient pre-injured, e.g. one hand-authored casualty that's part
        //    of a larger custom MCI built entirely out of these modules. Parsed by the shared
        //    afcm_sim_scenario_fnc_parseExportedPreset (also used by the Preset Library's own
        //    Import), which accepts EITHER real export shape: the full Preset envelope the Preset
        //    Library's own Export button produces (fnc_exportPreset.sqf -
        //    `[id, name, author, description, injuries, tags, katExtras?]`), or the leaner bare
        //    array a live patient's "Export Patient State" action produces on its own
        //    (fnc_exportPatientState.sqf - just `injuries`, or `[injuries, katExtras]` when there's
        //    KAT extras/cardiac state to carry - no id/name/author/description/tags noise). KAT
        //    extras, from either shape, are applied via afcm_sim_scenario_fnc_serverApplyKatExtras
        //    alongside the base injuries.
        //  - AFCM_SIM_SpawnMarkerName: where the patient actually spawns. Left blank (the default),
        //    behaviour is unchanged - the module's own placed position. Real, confirmed bug fixed
        //    here: an earlier pass also required a "Spawn at Synced Object" checkbox to be ticked
        //    before a synced object's position would be used at all, so simply syncing an object
        //    with the checkbox left at its default silently fell through to the module's own
        //    position - that checkbox is gone now. Any object synced to the module (Eden:
        //    Ctrl+click drag a sync line to it) now always wins; a non-blank marker name here is
        //    the fallback when nothing's synced (fnc_module_patientPlacement.sqf has the full
        //    precedence).
        class Attributes: AFCM_SIM_CasualtyTypeAttributes
        {
            class AFCM_SIM_InjuryPresetImport
            {
                displayName = "Injury Preset (paste to import)";
                tooltip = "Paste an exported Injury Preset or Patient State string here to spawn this patient pre-configured with those exact injuries (including any KAT fracture/pneumothorax/airway/cardiac state the export carries). Leave blank to spawn clean/unconscious (use the Edit Injuries action instead).";
                property = "AFCM_SIM_injuryPresetImport";
                control = "Edit";
                defaultValue = "";
                typeName = "STRING";
            };
            class AFCM_SIM_SpawnMarkerName
            {
                displayName = "Spawn Marker Name";
                tooltip = "Name of a placed marker to spawn the patient at. Ignored if an object is synced to this module (that always wins). Leave blank to spawn at the module's own placed position.";
                property = "AFCM_SIM_spawnMarkerName";
                control = "Edit";
                defaultValue = "";
                typeName = "STRING";
            };
        };
    };

    // Diegetic entry point for a training scenario: sync this module (or, in Zeus, drag it
    // directly onto the object - curatorCanAttach = 1) to any placed object - a Laptop_01_F, a
    // table, anything - and every player gets two real addActions on it, "AFCM: Open MCI Creator"
    // and "AFCM: Open Session Manager" (afcm_sim_ui_fnc_addTerminalAction), so a scenario can offer
    // "walk up to the laptop and build the incident" instead of requiring a keybind or Zeus.
    //
    // Target resolution supports both real placement paths at once: `_units` (synced units, Eden's
    // own mechanism - Ctrl+click sync line from module to object) is checked first, falling back to
    // `attachedTo _logic` (Zeus's drag-directly-onto-an-object mechanism, same as
    // AFCM_SIM_ModuleEditInjuries in zeus/config.cpp) if nothing was synced.
    class AFCM_SIM_ModuleInteractiveTerminal: Module_F
    {
        scope = 2;
        scopeCurator = 2;
        side = 7;
        displayName = "Interactive Terminal";
        icon = "\afcm_sim\addons\eden\data\module_mascal.paa";
        category = "AFCM_SIM_Category";
        function = "afcm_sim_eden_fnc_module_interactiveTerminal";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 1;
    };
};
