class CfgPatches
{
    class afcm_sim_eden
    {
        units[] = {"AFCM_SIM_ModulePatientPlacement", "AFCM_SIM_ModuleMascalZone", "AFCM_SIM_ModuleMciSpawnerPlacement", "AFCM_SIM_ModuleInteractiveTerminal", "AFCM_SIM_ModuleMedicalTent"};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main", "afcm_sim_scenario", "afcm_sim_spawner"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Eden (mission editor) modules — the design-time side of patient placement (DESIGN.md §5 "Map to
// Spawn Patients"), now calling real afcm_sim_spawner logic. `scope = 2;` makes every module below
// placeable in Eden as before; `scopeCurator` now varies per module rather than a blanket `2`:
//  - AFCM_SIM_ModulePatientPlacement / AFCM_SIM_ModuleMciSpawnerPlacement -> `scopeCurator = 0;`,
//    hidden from the Zeus curator browser. Zeus already has its own live counterparts doing the
//    exact same job at mission runtime (addons/zeus/config.cpp: Spawn Patient, MCI Spawner) - an
//    earlier pass showed both sets in Zeus "at no cost", which in practice just duplicated/confused
//    the module list with two near-identical entries for the same action.
//  - AFCM_SIM_ModuleMascalZone / AFCM_SIM_ModuleInteractiveTerminal / AFCM_SIM_ModuleMedicalTent ->
//    left at `scopeCurator = 2;`, unchanged. None of these three has a Zeus-side duplicate, so
//    there's no clutter to fix - and AFCM_SIM_ModuleInteractiveTerminal specifically NEEDS Zeus
//    visibility for its `curatorCanAttach = 1` drag-directly-onto-an-object mechanic to be
//    reachable at all (a module hidden from the curator browser can't be selected/dragged in Zeus
//    in the first place, regardless of curatorCanAttach).
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
            class module_interactiveTerminal { file = "\afcm_sim\addons\eden\functions\fnc_module_interactiveTerminal.sqf"; };
            class module_medicalTent { file = "\afcm_sim\addons\eden\functions\fnc_module_medicalTent.sqf"; };
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
        // AFCM_SIM_ModuleMascalZone below keeps its own Injury Level attribute - that one's still a
        // randomized batch-spawn tool.
        //
        // Casualty Type IS still an attribute here though - purely cosmetic (clothing/appearance),
        // not tied to the injury-randomization pipeline the Injury Level attribute controlled, so
        // it makes sense on a manually-treated single patient too.
        //
        // Three new attributes, all read back by fnc_module_patientPlacement.sqf:
        //  - AFCM_SIM_InjuryPresetImport: paste an exported Injury Preset/Patient State string
        //    (fnc_exportPreset.sqf / fnc_exportPatientState.sqf - same shape) to spawn this patient
        //    pre-injured, e.g. one hand-authored casualty that's part of a larger custom MCI built
        //    entirely out of these modules. Parsed by the shared
        //    afcm_sim_scenario_fnc_parseExportedPreset (also used by the Preset Library's own
        //    Import), so it accepts anything either the Preset Library's Export button or a live
        //    patient's "Export Patient State" action produces.
        //  - AFCM_SIM_UseSyncedPosition / AFCM_SIM_SpawnMarkerName: where the patient actually
        //    spawns. Default (both left as-is) is unchanged - the module's own placed position.
        //    Ticking "Spawn at Synced Object" spawns at the position of an object synced to this
        //    module instead (Eden: Ctrl+click drag a sync line to it); leaving it unticked but
        //    filling in a marker name spawns at that marker's position instead (e.g. an Empty
        //    marker under Markers > System - real, confirmed Eden marker type, chosen purely so it
        //    has no icon of its own cluttering the map). Synced-object position wins if both are
        //    set, since the checkbox is the explicit "prefer sync" toggle.
        class Attributes: AFCM_SIM_CasualtyTypeAttributes
        {
            class AFCM_SIM_InjuryPresetImport
            {
                displayName = "Injury Preset (paste to import)";
                tooltip = "Paste an exported Injury Preset or Patient State string here to spawn this patient pre-configured with those exact injuries. Leave blank to spawn clean/unconscious (use the Edit Injuries action instead).";
                property = "AFCM_SIM_injuryPresetImport";
                control = "Edit";
                defaultValue = "";
                typeName = "STRING";
            };
            class AFCM_SIM_UseSyncedPosition
            {
                displayName = "Spawn at Synced Object";
                tooltip = "If enabled, spawns the patient at the position of an object synced to this module instead of the module's own placed position. If disabled, the Spawn Marker Name field below is used instead (leave both empty/unset to use the module's own position).";
                property = "AFCM_SIM_useSyncedPosition";
                control = "Checkbox";
                defaultValue = "0";
                typeName = "BOOL";
            };
            class AFCM_SIM_SpawnMarkerName
            {
                displayName = "Spawn Marker Name";
                tooltip = "Name of a placed marker whose position to spawn the patient at, used only when 'Spawn at Synced Object' above is disabled. Leave blank to spawn at the module's own placed position.";
                property = "AFCM_SIM_spawnMarkerName";
                control = "Edit";
                defaultValue = "";
                typeName = "STRING";
            };
        };
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
        scopeCurator = 0;
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

    // Session-scoped treatment detection for a physical Medical Tent the mission maker builds
    // themselves out of real objects (a tent, screens, medical gear - however elaborate they want,
    // via a normal Eden Composition) - AFCM doesn't spawn or know about any of that scenery, it only
    // needs to know which placed objects act as stretchers.
    //
    // Sync every stretcher-ish object (any classname - a real stretcher prop, a cot, whatever the
    // composition uses) to this module - naming each one afcm_stretcher_1/afcm_stretcher_2/etc in
    // Eden's own object Name field first is the recommended convention (not parsed by the code,
    // purely so multiple stretchers/tents stay identifiable in the editor and in AFCM's own logs).
    // A Spawn Session (afcm_sim_spawner) counts as resolved once every one of its live patients is
    // simultaneously treated and within Stretcher Radius of any synced stretcher from ANY placed
    // Medical Tent - see fnc_module_medicalTent.sqf and afcm_sim_scenario_fnc_
    // startMedicalTentMonitor for the session-scoped, multi-tent-friendly detection logic.
    class AFCM_SIM_ModuleMedicalTent: Module_F
    {
        scope = 2;
        scopeCurator = 2;
        side = 7;
        displayName = "Medical Tent";
        icon = "\afcm_sim\addons\eden\data\module_mascal.paa";
        category = "AFCM_SIM_Category";
        function = "afcm_sim_eden_fnc_module_medicalTent";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 0;

        class Attributes
        {
            scope = 0;
            class AFCM_SIM_StretcherRadius
            {
                displayName = "Stretcher Radius (m)";
                tooltip = "How close a patient must be to a synced stretcher to count as 'on' it";
                property = "AFCM_SIM_stretcherRadius";
                control = "combo";
                defaultValue = "2";
                class Values
                {
                    class One { name = "1"; value = 1; };
                    class OnePointFive { name = "1.5"; value = 1.5; };
                    class Two { name = "2"; value = 2; default = 1; };
                    class Three { name = "3"; value = 3; };
                    class Four { name = "4"; value = 4; };
                };
            };
        };
    };
};
