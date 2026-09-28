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
            class resolvePatientAttributes { file = "\afcm_sim\addons\eden\functions\fnc_resolvePatientAttributes.sqf"; };
            class serverSpawnFromTerminal { file = "\afcm_sim\addons\eden\functions\fnc_serverSpawnFromTerminal.sqf"; };
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
        // Spawn Patient module - UNLESS Training Preset or Injury Preset Import (below) is set, in
        // which case the patient spawns pre-configured with those exact injuries instead.
        //
        // Casualty Type IS still an attribute here though - purely cosmetic (clothing/appearance),
        // not tied to the injury-randomization pipeline the old Injury Level attribute controlled,
        // so it makes sense on a manually-treated single patient too.
        //
        // Real, confirmed behaviour change: syncing ANY object to this module (Eden: Ctrl+click drag
        // a sync line to it) now means "spawn this patient on demand, via an interaction on that
        // object" instead of "spawn immediately at mission start" - a laptop, a table, anything.
        // fnc_module_patientPlacement.sqf resolves this at runtime (see its own comment); everything
        // below is the same regardless of which mode a given placed instance ends up in.
        //
        // Attributes, all read back by fnc_module_patientPlacement.sqf/fnc_resolvePatientAttributes.sqf:
        //  - AFCM_SIM_CasualtyType: clothing/appearance only (DESIGN.md §5), not tied to the
        //    injury-randomization pipeline the old Injury Level attribute controlled - purely
        //    cosmetic, so it makes sense on a manually-treated single patient too. Values must line up
        //    with the classname array in afcm_sim_spawner_fnc_spawnPatient
        //    (C_man_1/B_Soldier_F/O_Soldier_F/I_Soldier_F, all real, base-game classnames) and with
        //    afcm_sim_defaultCasualtyType's CBA setting (main/functions/fnc_settings_preInit.sqf) -
        //    keep all three in sync if this list ever changes.
        //  - AFCM_SIM_SessionName: optional free-text Spawn Session name (DESIGN.md § Spawn
        //    Sessions) - blank means the module function auto-generates one as before.
        //  - AFCM_SIM_Title: editor-only label, NOT the patient's in-game name (patients always get a
        //    random one, afcm_sim_spawner_fnc_spawnPatient) - has no effect at all unless this module
        //    is synced to an object (below), in which case that interaction's whole label becomes
        //    "AFCM: Spawn <Title>" (fnc_addSpawnPatientAction.sqf) instead of the generic "AFCM: Spawn
        //    Patient" - the one place multiple placed instances need to look distinct to a real
        //    player picking one off a synced laptop, not just to whoever's editing the mission.
        //  - AFCM_SIM_TrainingPreset: quick-pick a built-in training scenario (airway/fracture/
        //    hemorrhage/GSW/blast/etc.) instead of hand-pasting an export string below. Wins over
        //    Injury Preset Import when set to anything but "None" - see its own comment.
        //  - AFCM_SIM_InjuryPresetImport: paste an exported Injury Preset or Patient State string
        //    here to spawn this patient pre-injured with something not covered by Training Preset,
        //    e.g. one hand-authored casualty that's part of a larger custom MCI built entirely out of
        //    these modules. Only consulted when Training Preset is left on "None". Parsed by the
        //    shared afcm_sim_scenario_fnc_parseExportedPreset (also used by the Preset Library's own
        //    Import), which accepts EITHER real export shape: the full Preset envelope the Preset
        //    Library's own Export button produces (fnc_exportPreset.sqf -
        //    `[id, name, author, description, injuries, tags, katExtras?]`), or the leaner bare
        //    array a live patient's "Export Patient State" action produces on its own
        //    (fnc_exportPatientState.sqf - just `injuries`, or `[injuries, katExtras]` when there's
        //    KAT extras/cardiac state to carry - no id/name/author/description/tags noise).
        //  - AFCM_SIM_SpawnMarkerName: where patients spawn when nothing's synced to this module
        //    (auto-spawn mode) - a comma-separated LIST of exact marker names, not a prefix (real,
        //    confirmed fix: this used to be prefix-matched, so typing the markers' own full names
        //    comma-separated - the natural way to type it - matched nothing at all), so one module can
        //    seed a whole batch: place a "System: Marker" object per patient, give each one whatever
        //    Variable Name you like in ITS OWN attributes (not this module's), then list those exact
        //    names here separated by commas (e.g. "Patient_1, Patient_2, Patient_3") - one patient
        //    spawns per listed name that actually resolves to a placed marker, sharing this module's
        //    same Casualty Type/Training Preset. A single name (no comma) still works exactly as
        //    before - just the one patient at that one marker. Leave blank to spawn one patient at
        //    this module's own placed position instead. Has no effect at all once an object is synced
        //    (on-demand mode) - position there always comes from the synced object itself.
        //
        // Real, confirmed Eden bug fixed here: CasualtyType/SessionName/Title used to live on a
        // separate shared `AFCM_SIM_CasualtyTypeAttributes: Module_F` base class that this Attributes
        // class inherited from (`class Attributes: AFCM_SIM_CasualtyTypeAttributes`) purely to avoid
        // repeating them - the config itself resolved that inheritance correctly (confirmed by
        // derapifying the actual built config.bin), but Eden's own "System Specific" attribute panel
        // does NOT walk a class's inheritance chain when deciding what to display - it only shows
        // attributes declared DIRECTLY in this class's own body. Every attribute inherited from that
        // base class was invisible in Eden even though it was genuinely present in the compiled
        // config - confirmed from a real screenshot showing only the 3 attributes already declared
        // directly here (Training Preset/Injury Preset/Spawn Marker Name). Fixed by moving
        // CasualtyType/SessionName/Title directly into this class's own body instead of inheriting
        // them - the shared base class is gone now (nothing else in this file used it;
        // addons/zeus/config.cpp has always kept its own fully independent copy, unaffected by this).
        class Attributes
        {
            class AFCM_SIM_CasualtyType
            {
                displayName = "Casualty Type";
                property = "AFCM_SIM_casualtyType";
                control = "combo";
                defaultValue = "0";
                // Real, confirmed root-cause bug fixed here (this class and every other one in this
                // Attributes block): a custom Eden attribute is NOT automatically written onto the
                // placed object via setVariable just from having a `property=` - that's purely the
                // variable NAME to use if/when something actually calls setVariable. The actual write
                // only happens through an explicit `expression=`, run by Eden itself whenever the
                // attribute's value changes AND again at scenario start (confirmed against Bohemia's
                // own wiki - Eden Editor: Configuring Attributes). Every attribute below had a
                // `property=` but no `expression=` at all, so NONE of them were ever actually being
                // set on the object - confirmed via a real RPT test where all 6 attributes read back
                // as unset despite several being visibly non-default in Eden's own dialog. `_this` is
                // the placed object, `_value` is the attribute's current value.
                // parseNumber - real, confirmed bug: a combo's _value arrives at this expression as a
                // STRING (matching `defaultValue`'s own string-typed "0" here), not the numeric
                // `value=` from Values below - confirmed via a real RPT error downstream
                // (fnc_resolvePatientAttributes.sqf: "Type String, expected Number" comparing a
                // combo-sourced variable). Edit/STRING-typed attributes elsewhere in this file don't
                // need this - their downstream code already expects a string.
                expression = "_this setVariable ['AFCM_SIM_casualtyType', parseNumber _value];";
                class Values
                {
                    class Civilian { name = "Civilian"; value = 0; default = 1; };
                    class MilitaryBlufor { name = "Military (BLUFOR)"; value = 1; };
                    class MilitaryOpfor { name = "Military (OPFOR)"; value = 2; };
                    class MilitaryIndependent { name = "Military (Independent)"; value = 3; };
                };
            };
            class AFCM_SIM_SessionName
            {
                displayName = "Session Name (optional)";
                property = "AFCM_SIM_sessionName";
                control = "Edit";
                defaultValue = "";
                typeName = "STRING";
                expression = "_this setVariable ['AFCM_SIM_sessionName', _value];";
            };
            class AFCM_SIM_Title
            {
                displayName = "Title (editor-only)";
                tooltip = "A label to tell multiple placed AFCM Patient modules apart - in Eden, AND on the interaction if this module is synced to an object (reads 'AFCM: Spawn <Title>' instead of the generic 'AFCM: Spawn Patient'). Never applied to the patient itself as a name - patients always get a random name.";
                property = "AFCM_SIM_title";
                control = "Edit";
                defaultValue = "";
                typeName = "STRING";
                expression = "_this setVariable ['AFCM_SIM_title', _value];";
            };
            class AFCM_SIM_TrainingPreset
            {
                displayName = "Training Preset (quick pick)";
                tooltip = "Quick-pick a built-in training scenario instead of hand-pasting an export string below. Wins over Injury Preset Import when set to anything but None.";
                property = "AFCM_SIM_trainingPreset";
                control = "combo";
                defaultValue = "0";
                // parseNumber - same combo-value-arrives-as-a-string issue as AFCM_SIM_CasualtyType
                // above, confirmed via a real RPT error here specifically (this attribute's own
                // index compared with `> 0` in fnc_resolvePatientAttributes.sqf).
                expression = "_this setVariable ['AFCM_SIM_trainingPreset', parseNumber _value];";
                // Values here are positional indices into afcm_sim_scenario_fnc_getBuiltinPresets.sqf's
                // own array (value N -> that array's index N-1) - deliberately an index, not a
                // duplicated id string, to avoid a second hardcoded list drifting out of sync. If that
                // file's array ever changes order/count, this list MUST be updated to match - see its
                // own comment, which points back here.
                class Values
                {
                    class None { name = "None (use paste below)"; value = 0; default = 1; };
                    class GswChest { name = "GSW - Chest"; value = 1; };
                    class GswLimbTq { name = "GSW - Limb (Tourniquet Candidate)"; value = 2; };
                    class BlastCasualty { name = "Blast Casualty"; value = 3; };
                    class FragMultiple { name = "Frag Wounds (Multiple)"; value = 4; };
                    class MinorLaceration { name = "Training - Minor Laceration"; value = 5; };
                    class AirwayObstruction { name = "Airway - Obstruction"; value = 6; };
                    class FractureMultiple { name = "Fractures - Multiple Limb"; value = 7; };
                    class SevereHemorrhage { name = "Severe Hemorrhage (Multi-Site)"; value = 8; };
                };
            };
            class AFCM_SIM_InjuryPresetImport
            {
                displayName = "Injury Preset (paste to import)";
                tooltip = "Only used when Training Preset above is left on None. Paste an exported Injury Preset or Patient State string here to spawn this patient pre-configured with those exact injuries (including any KAT fracture/pneumothorax/airway/cardiac state the export carries). Leave blank to spawn clean/unconscious (use the Edit Injuries action instead).";
                property = "AFCM_SIM_injuryPresetImport";
                control = "Edit";
                defaultValue = "";
                typeName = "STRING";
                expression = "_this setVariable ['AFCM_SIM_injuryPresetImport', _value];";
            };
            class AFCM_SIM_SpawnMarkerName
            {
                displayName = "Spawn Marker Name(s)";
                tooltip = "Only used when nothing is synced to this module. Comma-separated list of exact placed marker names - one patient spawns at each one that resolves (e.g. 'Patient_1, Patient_2, Patient_3'). A single name with no comma still works as before, spawning just the one patient. Leave blank to spawn at this module's own placed position instead.";
                property = "AFCM_SIM_spawnMarkerName";
                control = "Edit";
                defaultValue = "";
                typeName = "STRING";
                expression = "_this setVariable ['AFCM_SIM_spawnMarkerName', _value];";
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
