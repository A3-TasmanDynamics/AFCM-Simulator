class CfgPatches
{
    class afcm_sim_scenario
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Domain logic: injury model, preset library, randomization profiles (DESIGN.md §3/§4). Calls the
// backend interface (afcm_sim_fnc_backend_*, owned by afcm_sim_main) once it needs to apply
// anything; never AFCM or ACE3 directly. NOTE: explicit `file=`, full absolute virtual path — see
// afcm_sim_main/config.cpp for why both the fnc_ filename AND the absolute-path form are required.
class CfgFunctions
{
    class afcm_sim_scenario
    {
        tag = "afcm_sim_scenario";
        class Functions
        {
            file = "\afcm_sim\addons\scenario\functions";
            class randomizeInjuries { file = "\afcm_sim\addons\scenario\functions\fnc_randomizeInjuries.sqf"; };
            class serverApplyInjury { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyInjury.sqf"; };
            class serverReset { file = "\afcm_sim\addons\scenario\functions\fnc_serverReset.sqf"; };
            class buildInjury { file = "\afcm_sim\addons\scenario\functions\fnc_buildInjury.sqf"; };
            class serverApplyKatFracture { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyKatFracture.sqf"; };
            class serverApplyKatPneumothorax { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyKatPneumothorax.sqf"; };
            class serverApplyKatAirway { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyKatAirway.sqf"; };
            // Unlike the three above, NOT KAT-only - the base cardiac arrest flag is genuinely
            // ACE-native, so this dispatches to whichever of "ace"/"kat" is actually active. See
            // fnc_serverApplyCardiacState.sqf's own header.
            class serverApplyCardiacState { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyCardiacState.sqf"; };
        };
        // Injury Presets (DESIGN.md §4.3/§ Injury Presets) - built-in library + a per-player
        // profileNamespace-backed user library, plain-Array export/import, and the server-side
        // batch-apply handler. Separate class purely for readability; same tag/file path.
        class Presets
        {
            file = "\afcm_sim\addons\scenario\functions";
            class getBuiltinPresets { file = "\afcm_sim\addons\scenario\functions\fnc_getBuiltinPresets.sqf"; };
            class getUserPresets { file = "\afcm_sim\addons\scenario\functions\fnc_getUserPresets.sqf"; };
            class saveUserPreset { file = "\afcm_sim\addons\scenario\functions\fnc_saveUserPreset.sqf"; };
            class deleteUserPreset { file = "\afcm_sim\addons\scenario\functions\fnc_deleteUserPreset.sqf"; };
            class exportPreset { file = "\afcm_sim\addons\scenario\functions\fnc_exportPreset.sqf"; };
            class importPreset { file = "\afcm_sim\addons\scenario\functions\fnc_importPreset.sqf"; };
            class serverApplyPreset { file = "\afcm_sim\addons\scenario\functions\fnc_serverApplyPreset.sqf"; };
            class findPreset { file = "\afcm_sim\addons\scenario\functions\fnc_findPreset.sqf"; };
        };
        // MCI (Mass Casualty Incident) presets - a named INCIDENT, not a single injury: each
        // patient slot carries its own Preset id (or "random"), resolved independently per patient
        // at spawn time (fnc_resolveMciPatientSpec.sqf). Same built-in + profileNamespace user
        // library / plain-Array export-import pattern as Presets above, separate library/key.
        class MciPresets
        {
            file = "\afcm_sim\addons\scenario\functions";
            class getBuiltinMciPresets { file = "\afcm_sim\addons\scenario\functions\fnc_getBuiltinMciPresets.sqf"; };
            class getUserMciPresets { file = "\afcm_sim\addons\scenario\functions\fnc_getUserMciPresets.sqf"; };
            class saveUserMciPreset { file = "\afcm_sim\addons\scenario\functions\fnc_saveUserMciPreset.sqf"; };
            class deleteUserMciPreset { file = "\afcm_sim\addons\scenario\functions\fnc_deleteUserMciPreset.sqf"; };
            class exportMciPreset { file = "\afcm_sim\addons\scenario\functions\fnc_exportMciPreset.sqf"; };
            class importMciPreset { file = "\afcm_sim\addons\scenario\functions\fnc_importMciPreset.sqf"; };
            class findMciPreset { file = "\afcm_sim\addons\scenario\functions\fnc_findMciPreset.sqf"; };
            class resolveMciPatientSpec { file = "\afcm_sim\addons\scenario\functions\fnc_resolveMciPatientSpec.sqf"; };
            class serverSpawnMci { file = "\afcm_sim\addons\scenario\functions\fnc_serverSpawnMci.sqf"; };
        };
        // Medical Tent (DESIGN.md § Medical Tent) - session-scoped treatment detection, not a
        // spawned object of its own. A Spawn Session (afcm_sim_spawner) is "resolved" once every
        // live patient in it is both treated (isPatientTreated) and physically on a registered
        // stretcher (isPatientOnStretcher) - checked by one server-side monitor loop shared across
        // every placed Medical Tent module, not one loop per tent, so multiple tents/sessions
        // resolve independently without duplicating the poll.
        class MedicalTent
        {
            file = "\afcm_sim\addons\scenario\functions";
            class registerMedicalTent { file = "\afcm_sim\addons\scenario\functions\fnc_registerMedicalTent.sqf"; };
            class startMedicalTentMonitor { file = "\afcm_sim\addons\scenario\functions\fnc_startMedicalTentMonitor.sqf"; };
            class isPatientTreated { file = "\afcm_sim\addons\scenario\functions\fnc_isPatientTreated.sqf"; };
            class isPatientOnStretcher { file = "\afcm_sim\addons\scenario\functions\fnc_isPatientOnStretcher.sqf"; };
            class serverMarkTreated { file = "\afcm_sim\addons\scenario\functions\fnc_serverMarkTreated.sqf"; };
        };
    };
};
