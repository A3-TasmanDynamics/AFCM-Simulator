class CfgPatches
{
    class afcm_sim_ui
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "afcm_sim_main", "afcm_sim_scenario", "afcm_sim_spawner"};
        author = "Tasman Dynamics";
        authors[] = {"Tasman Dynamics"};
        version = "0.1.0";
    };
};

// Native-dialog component kit + event bus (DESIGN.md §2.4/§3). Dialogs publish onto the bus
// (fnc_publish) rather than calling afcm_sim_scenario directly, and domain logic subscribes
// (fnc_subscribe) rather than dialogs calling it directly — so a future Phase-2 overlay frontend
// (DESIGN.md §2.3) could publish onto the same bus without this side changing at all.
//
// NOTE: explicit `file=` per leaf class, as a full absolute virtual path (matching $PBOPREFIX$) —
// see afcm_sim_main/config.cpp for why both the fnc_ filename AND the absolute-path form are
// required (neither `hemtt build` nor `hemtt check` catch either mistake; only an actual in-game
// launch does).
class CfgFunctions
{
    class afcm_sim_ui
    {
        tag = "afcm_sim_ui";
        class EventBus
        {
            file = "\afcm_sim\addons\ui\functions";
            class publish { file = "\afcm_sim\addons\ui\functions\fnc_publish.sqf"; };
            class subscribe { file = "\afcm_sim\addons\ui\functions\fnc_subscribe.sqf"; };
        };
        // Replaces the old LimbSelect + InjuryEditor classes (both retired dialogs deleted outright
        // - see addons/ui/config.cpp's own comment above RscDisplayAFCM_SIM_InjuryAuthor for why).
        class InjuryAuthor
        {
            file = "\afcm_sim\addons\ui\functions";
            class injuryAuthor_open { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_open.sqf"; };
            class injuryAuthor_init { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_init.sqf"; };
            class injuryAuthor_cleanup { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_cleanup.sqf"; };
            class injuryAuthor_onNavClick { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onNavClick.sqf"; };
            class injuryAuthor_setActiveLimb { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_setActiveLimb.sqf"; };
            class injuryAuthor_commitActiveLimbForm { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_commitActiveLimbForm.sqf"; };
            class injuryAuthor_refreshActiveLimbForm { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_refreshActiveLimbForm.sqf"; };
            class injuryAuthor_refreshNavbar { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_refreshNavbar.sqf"; };
            class injuryAuthor_onApply { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onApply.sqf"; };
            class injuryAuthor_onResetLimb { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onResetLimb.sqf"; };
            class injuryAuthor_onResetPatient { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onResetPatient.sqf"; };
            class injuryAuthor_onSavePreset { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onSavePreset.sqf"; };
            class injuryAuthor_onLoadPreset { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onLoadPreset.sqf"; };
            class injuryAuthor_loadPresetArrays { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_loadPresetArrays.sqf"; };
            class injuryAuthor_onExport { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onExport.sqf"; };
            class injuryAuthor_onImport { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onImport.sqf"; };
            class injuryAuthor_onClearAll { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onClearAll.sqf"; };
            class injuryAuthor_onRandomDamage { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onRandomDamage.sqf"; };
            class injuryAuthor_onChooseLocation { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_onChooseLocation.sqf"; };
            class injuryAuthor_refreshLocationStatus { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_refreshLocationStatus.sqf"; };
            class injuryAuthor_refreshState { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_refreshState.sqf"; };
            class injuryAuthor_loadFromUnit { file = "\afcm_sim\addons\ui\functions\fnc_injuryAuthor_loadFromUnit.sqf"; };
            class addInjuryEditorAction { file = "\afcm_sim\addons\ui\functions\fnc_addInjuryEditorAction.sqf"; };
            class addTreatedAction { file = "\afcm_sim\addons\ui\functions\fnc_addTreatedAction.sqf"; };
            class addExportStateAction { file = "\afcm_sim\addons\ui\functions\fnc_addExportStateAction.sqf"; };
        };
        class Mci
        {
            file = "\afcm_sim\addons\ui\functions";
            class addMciPresetAction { file = "\afcm_sim\addons\ui\functions\fnc_addMciPresetAction.sqf"; };
        };
        class PresetLibrary
        {
            file = "\afcm_sim\addons\ui\functions";
            class presetLibrary_init { file = "\afcm_sim\addons\ui\functions\fnc_presetLibrary_init.sqf"; };
            class presetLibrary_populateList { file = "\afcm_sim\addons\ui\functions\fnc_presetLibrary_populateList.sqf"; };
            class presetLibrary_onSelect { file = "\afcm_sim\addons\ui\functions\fnc_presetLibrary_onSelect.sqf"; };
            class presetLibrary_onApply { file = "\afcm_sim\addons\ui\functions\fnc_presetLibrary_onApply.sqf"; };
            class presetLibrary_onDelete { file = "\afcm_sim\addons\ui\functions\fnc_presetLibrary_onDelete.sqf"; };
            class presetLibrary_onExport { file = "\afcm_sim\addons\ui\functions\fnc_presetLibrary_onExport.sqf"; };
            class presetLibrary_onImport { file = "\afcm_sim\addons\ui\functions\fnc_presetLibrary_onImport.sqf"; };
        };
        class PresetSave
        {
            file = "\afcm_sim\addons\ui\functions";
            class presetSave_init { file = "\afcm_sim\addons\ui\functions\fnc_presetSave_init.sqf"; };
            class presetSave_onSave { file = "\afcm_sim\addons\ui\functions\fnc_presetSave_onSave.sqf"; };
        };
        // MCI Creator - a standalone, on-demand tool (DESIGN.md § MCI Creator): pick a patient
        // count, assign each patient its own Preset (or "random") independently, pick a spot on
        // the real map, spawn the whole incident in one request. Entry point:
        // afcm_sim_ui_fnc_mciCreator_open (also bound to a CBA keybind, afcm_sim_main).
        class MciCreator
        {
            file = "\afcm_sim\addons\ui\functions";
            class mciCreator_open { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_open.sqf"; };
            class mciCreator_init { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_init.sqf"; };
            class mciCreator_populatePatientList { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_populatePatientList.sqf"; };
            class mciCreator_populatePresetList { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_populatePresetList.sqf"; };
            class mciCreator_refreshLocationStatus { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_refreshLocationStatus.sqf"; };
            class mciCreator_onPatientCountChanged { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_onPatientCountChanged.sqf"; };
            class mciCreator_onAssign { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_onAssign.sqf"; };
            class mciCreator_onRandomizeAll { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_onRandomizeAll.sqf"; };
            class mciCreator_onChooseLocation { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_onChooseLocation.sqf"; };
            class mciCreator_onSpawn { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_onSpawn.sqf"; };
            class mciCreator_onSavePreset { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_onSavePreset.sqf"; };
            class mciCreator_onLoadPreset { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_onLoadPreset.sqf"; };
            class mciCreator_onManageSessions { file = "\afcm_sim\addons\ui\functions\fnc_mciCreator_onManageSessions.sqf"; };
        };
        // Real interactive map-click position picker (RscMapControl-based) - see
        // ui/config.cpp's RscDisplayAFCM_SIM_MapPicker for the full explanation.
        class MapPicker
        {
            file = "\afcm_sim\addons\ui\functions";
            class mapPicker_init { file = "\afcm_sim\addons\ui\functions\fnc_mapPicker_init.sqf"; };
            class mapPicker_onClick { file = "\afcm_sim\addons\ui\functions\fnc_mapPicker_onClick.sqf"; };
            class mapPicker_onConfirm { file = "\afcm_sim\addons\ui\functions\fnc_mapPicker_onConfirm.sqf"; };
            class mapPicker_cleanup { file = "\afcm_sim\addons\ui\functions\fnc_mapPicker_cleanup.sqf"; };
        };
        // MCI Preset library (INJURY_CODES.md §4/DESIGN.md § MCI Creator) - same shape as
        // PresetLibrary above, for whole incidents instead of single injuries. "Load" replaces the
        // MCI Creator's patient list rather than applying to a unit.
        class MciPresetLibrary
        {
            file = "\afcm_sim\addons\ui\functions";
            class mciPresetLibrary_init { file = "\afcm_sim\addons\ui\functions\fnc_mciPresetLibrary_init.sqf"; };
            class mciPresetLibrary_populateList { file = "\afcm_sim\addons\ui\functions\fnc_mciPresetLibrary_populateList.sqf"; };
            class mciPresetLibrary_onSelect { file = "\afcm_sim\addons\ui\functions\fnc_mciPresetLibrary_onSelect.sqf"; };
            class mciPresetLibrary_onLoad { file = "\afcm_sim\addons\ui\functions\fnc_mciPresetLibrary_onLoad.sqf"; };
            class mciPresetLibrary_onDelete { file = "\afcm_sim\addons\ui\functions\fnc_mciPresetLibrary_onDelete.sqf"; };
            class mciPresetLibrary_onExport { file = "\afcm_sim\addons\ui\functions\fnc_mciPresetLibrary_onExport.sqf"; };
            class mciPresetLibrary_onImport { file = "\afcm_sim\addons\ui\functions\fnc_mciPresetLibrary_onImport.sqf"; };
        };
        class MciPresetSave
        {
            file = "\afcm_sim\addons\ui\functions";
            class mciPresetSave_init { file = "\afcm_sim\addons\ui\functions\fnc_mciPresetSave_init.sqf"; };
            class mciPresetSave_onSave { file = "\afcm_sim\addons\ui\functions\fnc_mciPresetSave_onSave.sqf"; };
        };
        // Spawn Sessions - see ui/config.cpp's RscDisplayAFCM_SIM_SessionManager for the full
        // explanation. Entry point: afcm_sim_ui_fnc_sessionManager_open (also bound to a CBA
        // keybind, afcm_sim_main, and reachable from the MCI Creator's own "Manage Sessions" button).
        class SessionManager
        {
            file = "\afcm_sim\addons\ui\functions";
            class sessionManager_open { file = "\afcm_sim\addons\ui\functions\fnc_sessionManager_open.sqf"; };
            class sessionManager_init { file = "\afcm_sim\addons\ui\functions\fnc_sessionManager_init.sqf"; };
            class sessionManager_populateList { file = "\afcm_sim\addons\ui\functions\fnc_sessionManager_populateList.sqf"; };
            class sessionManager_onSelect { file = "\afcm_sim\addons\ui\functions\fnc_sessionManager_onSelect.sqf"; };
            class sessionManager_onDeleteSession { file = "\afcm_sim\addons\ui\functions\fnc_sessionManager_onDeleteSession.sqf"; };
            class sessionManager_onClearAll { file = "\afcm_sim\addons\ui\functions\fnc_sessionManager_onClearAll.sqf"; };
        };
        // Generic reusable Yes/No confirmation - see ui/config.cpp's RscDisplayAFCM_SIM_ConfirmDialog.
        class ConfirmDialog
        {
            file = "\afcm_sim\addons\ui\functions";
            class confirmDialog_open { file = "\afcm_sim\addons\ui\functions\fnc_confirmDialog_open.sqf"; };
            class confirmDialog_init { file = "\afcm_sim\addons\ui\functions\fnc_confirmDialog_init.sqf"; };
            class confirmDialog_onYes { file = "\afcm_sim\addons\ui\functions\fnc_confirmDialog_onYes.sqf"; };
        };
        // Interactive Terminal - see eden/config.cpp's AFCM_SIM_ModuleInteractiveTerminal. Adds two
        // vanilla addActions ("AFCM: Open MCI Creator" / "AFCM: Open Session Manager") to whatever
        // object the module is attached to, e.g. a placed Laptop_01_F, so a training scenario can
        // give players/curators a diegetic way in without needing a keybind or the Zeus interface.
        class InteractiveTerminal
        {
            file = "\afcm_sim\addons\ui\functions";
            class addTerminalAction { file = "\afcm_sim\addons\ui\functions\fnc_addTerminalAction.sqf"; };
        };
        // Generic AFCM-branded toast (RscDisplayAFCM_SIM_Toast, cutRsc-based, below) - a passive
        // HUD overlay, not a dialog, so it never steals input focus from Zeus or whatever else is
        // open. afcm_sim_scenario_fnc_startMedicalTentMonitor's session-resolved check is its first
        // real caller (via afcm_sim_ui_fnc_notifySessionResolved).
        class Toast
        {
            file = "\afcm_sim\addons\ui\functions";
            class showToast { file = "\afcm_sim\addons\ui\functions\fnc_showToast.sqf"; };
            class toast_init { file = "\afcm_sim\addons\ui\functions\fnc_toast_init.sqf"; };
            class notifySessionResolved { file = "\afcm_sim\addons\ui\functions\fnc_notifySessionResolved.sqf"; };
        };
    };
};

// AFCM brand palette (matches docs/assets/icon-src/*.svg: #c1272d red / #f2efe6 off-white),
// shared by both dialogs below so the whole UI kit reads as one consistent look rather than
// stock-gray engine dialogs. Alpha channel used to keep the panel/backdrop readable over
// whatever's behind it in-world without fully blocking the view.
#define AFCM_SIM_COLOR_PANEL          {0.05, 0.05, 0.055, 0.88}
#define AFCM_SIM_COLOR_ACCENT         {0.757, 0.153, 0.176, 1}
#define AFCM_SIM_COLOR_ACCENT_DIM     {0.757, 0.153, 0.176, 0.28}
#define AFCM_SIM_COLOR_ACCENT_HOVER   {0.757, 0.153, 0.176, 0.85}
#define AFCM_SIM_COLOR_TEXT           {0.949, 0.937, 0.902, 1}
#define AFCM_SIM_COLOR_TEXT_DIM       {0.75, 0.72, 0.68, 1}
#define AFCM_SIM_COLOR_BTN_BG         {0.12, 0.12, 0.135, 0.92}
#define AFCM_SIM_COLOR_BTN_DISABLED   {0.08, 0.08, 0.09, 0.55}
#define AFCM_SIM_COLOR_DANGER_BG      {0.42, 0.1, 0.09, 0.9}
#define AFCM_SIM_COLOR_DANGER_HOVER   {0.65, 0.13, 0.11, 1}
#define AFCM_SIM_COLOR_STATUS_BG      {0.02, 0.02, 0.025, 0.72}

class RscText;
class RscButton;
class RscCombo;
class RscListBox;
class RscEdit;
class RscMapControl;

// Shared component kit, built on the three real base classes above (already proven working in
// this file) rather than an unverified "RscBackground" class — RscText's own colorBackground[]
// (a standard property on any control, not RscText-specific) is enough to draw a flat panel/bar
// with idc=-1 and empty text.
class AFCM_SIM_Panel: RscText
{
    idc = -1;
    text = "";
    colorText[] = {0, 0, 0, 0};
    colorBackground[] = AFCM_SIM_COLOR_PANEL;
};
class AFCM_SIM_AccentBar: RscText
{
    idc = -1;
    text = "";
    colorText[] = {0, 0, 0, 0};
    colorBackground[] = AFCM_SIM_COLOR_ACCENT;
};
class AFCM_SIM_RscTitle: RscText
{
    colorText[] = AFCM_SIM_COLOR_TEXT;
    font = "PuristaBold";
    shadow = 1;
};
class AFCM_SIM_RscSubtitle: RscText
{
    colorText[] = AFCM_SIM_COLOR_TEXT_DIM;
    shadow = 1;
};
class AFCM_SIM_RscLabel: RscText
{
    colorText[] = AFCM_SIM_COLOR_TEXT;
    shadow = 1;
};
// Base button: dark, translucent, brand-red highlight on hover/focus so it's obvious what you're
// about to click — the stock RscButton hover state is a barely-visible shade of gray (see the
// "Right Leg" button in the reported screenshot). `colorFocused` is deliberately set to the exact
// same value as `colorBackgroundActive` (not a separate, dimmer color like this class used to
// define for it) — real, confirmed fix for a reported "flashing" bug:
// whichever button was last clicked keeps engine focus, and Arma toggles between the focus color
// and the hover color as the cursor crosses the button's edge, which reads as a flicker/flash
// whenever those two colors actually differ. Making them identical removes the visible toggle
// entirely while keeping the same "still obviously highlighted" goal this class already had -
// selection state itself is still shown via `ctrlSetBackgroundColor` at runtime
// (fnc_limbSelect_refreshButtons.sqf / fnc_injuryAuthor_refreshNavbar.sqf), a static recolor, not
// blinking either.
class AFCM_SIM_RscButton: RscButton
{
    colorBackground[] = AFCM_SIM_COLOR_BTN_BG;
    colorBackgroundActive[] = AFCM_SIM_COLOR_ACCENT_HOVER;
    colorBackgroundDisabled[] = AFCM_SIM_COLOR_BTN_DISABLED;
    colorFocused[] = AFCM_SIM_COLOR_ACCENT_HOVER;
    colorText[] = AFCM_SIM_COLOR_TEXT;
    colorDisabled[] = AFCM_SIM_COLOR_TEXT_DIM;
    sizeEx = "0.022 * safeZoneH";
    shadow = 1;
};
// Confirm-style action (Apply) - accent-tinted at rest, not just on hover, so it reads as the
// primary/default action in the row.
class AFCM_SIM_RscButtonPrimary: AFCM_SIM_RscButton
{
    colorBackground[] = AFCM_SIM_COLOR_ACCENT_DIM;
};
// Destructive-style action (Reset Patient) - solid red at rest, brighter on hover.
class AFCM_SIM_RscButtonDanger: AFCM_SIM_RscButton
{
    colorBackground[] = AFCM_SIM_COLOR_DANGER_BG;
    colorBackgroundActive[] = AFCM_SIM_COLOR_DANGER_HOVER;
};

#define IDD_AFCM_SIM_PRESETLIBRARY 25603

#define IDC_AFCM_SIM_PL_TITLE   1
#define IDC_AFCM_SIM_PL_LIST    10
#define IDC_AFCM_SIM_PL_APPLY   11
#define IDC_AFCM_SIM_PL_DELETE  12
#define IDC_AFCM_SIM_PL_EXPORT  13
#define IDC_AFCM_SIM_PL_TEXT    14
#define IDC_AFCM_SIM_PL_IMPORT  15
#define IDC_AFCM_SIM_PL_CLOSE   16
#define IDC_AFCM_SIM_PL_SUBTITLE 17

// Third real screen — Injury Presets (DESIGN.md § Injury Presets/§4.3): a listbox of built-in
// (id prefix "builtin_", shipped in fnc_getBuiltinPresets.sqf) + user-saved presets (per-player
// profileNamespace, fnc_getUserPresets.sqf), each row's real preset id stashed via `lbSetData` so
// fnc_presetLibrary_* handlers can look the exact preset up without re-parsing display text.
// Opened from the limb-select ("main") screen's own Presets button.
//
// Apply applies every injury in the selected preset to the target unit in one request
// (afcm_sim_scenario_fnc_serverApplyPreset, same server-authoritative pattern as everything else,
// DESIGN.md §6). Delete only works on user presets (built-in ones are read-only) —
// fnc_presetLibrary_onDelete.sqf guards this too, not just the UI. Export/Import share one text
// field (Text, an RscEdit — plain single-line, since the exported string has no embedded
// newlines): Export fills it with the selected preset's exported string (fnc_exportPreset.sqf) and
// copies it to the OS clipboard (`copyToClipboard`, real command) for pasting elsewhere; Import
// reads whatever's typed/pasted into it and adds it as a new user preset
// (fnc_importPreset.sqf) — pasting into an RscEdit is native OS textbox behaviour (Ctrl+V), nothing
// scripted needed for that half.
class RscDisplayAFCM_SIM_PresetLibrary
{
    idd = IDD_AFCM_SIM_PRESETLIBRARY;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_presetLibrary_init;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.25 * safeZoneW + safeZoneX";
            y = "0.21 * safeZoneH + safeZoneY";
            w = "0.5 * safeZoneW";
            h = "0.58 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_PL_TITLE;
            text = "Injury Preset Library";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.23 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.03 * safeZoneH";
        };
        // Text set dynamically in fnc_presetLibrary_populateList.sqf - reads differently in MCI
        // batch mode (AFCM_SIM_UI_targetUnits set) vs the normal single-patient flow.
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = IDC_AFCM_SIM_PL_SUBTITLE;
            text = "Apply a saved injury set, or export/import one below";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.268 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.017 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.3 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class List: RscListBox
        {
            idc = IDC_AFCM_SIM_PL_LIST;
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.31 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.28 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_STATUS_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
            colorSelect[] = AFCM_SIM_COLOR_TEXT;
            colorSelectBackground[] = AFCM_SIM_COLOR_ACCENT_HOVER;
            sizeEx = "0.019 * safeZoneH";
        };
        class Apply: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_PL_APPLY;
            text = "Apply";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.6 * safeZoneH + safeZoneY";
            w = "0.146 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        // Only meaningful for a selected user preset - disabled by fnc_presetLibrary_onSelect.sqf
        // when a built-in row (id prefix "builtin_") is selected. fnc_deleteUserPreset.sqf guards
        // this server-side-of-truth too, so this is UX, not the only safeguard.
        class Delete: AFCM_SIM_RscButtonDanger
        {
            idc = IDC_AFCM_SIM_PL_DELETE;
            text = "Delete";
            x = "0.427 * safeZoneW + safeZoneX";
            y = "0.6 * safeZoneH + safeZoneY";
            w = "0.146 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Export: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_PL_EXPORT;
            text = "Export ↓";
            x = "0.584 * safeZoneW + safeZoneX";
            y = "0.6 * safeZoneH + safeZoneY";
            w = "0.146 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class TextLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Preset string (select all, Ctrl+C to copy — Ctrl+V to paste, then Import)";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.65 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.016 * safeZoneH";
        };
        class Text: RscEdit
        {
            idc = IDC_AFCM_SIM_PL_TEXT;
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.675 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_BTN_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
        };
        class Import: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_PL_IMPORT;
            text = "Import ↑";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.725 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Close: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_PL_CLOSE;
            text = "Close";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.725 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.04 * safeZoneH";
            action = "closeDialog 0;";
        };
    };
};

#define IDD_AFCM_SIM_PRESETSAVE 25604

#define IDC_AFCM_SIM_PSV_TITLE  1
#define IDC_AFCM_SIM_PSV_NAME   10
#define IDC_AFCM_SIM_PSV_SAVE   11
#define IDC_AFCM_SIM_PSV_CANCEL 12

// Tiny fourth screen - just a name prompt, opened by the injury editor's Save as Preset button
// (fnc_injuryEditor_onSavePreset.sqf, which stashes the currently-configured injury into
// AFCM_SIM_UI_pendingPresetInjuries before opening this). Save reads the name and calls
// afcm_sim_scenario_fnc_saveUserPreset directly (client-side, profileNamespace - not a server
// request, since this never touches a patient, DESIGN.md § Injury Presets).
class RscDisplayAFCM_SIM_PresetSave
{
    idd = IDD_AFCM_SIM_PRESETSAVE;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_presetSave_init;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.39 * safeZoneH + safeZoneY";
            w = "0.36 * safeZoneW";
            h = "0.22 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_PSV_TITLE;
            text = "Save Injury Preset";
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.41 * safeZoneH + safeZoneY";
            w = "0.32 * safeZoneW";
            h = "0.035 * safeZoneH";
            sizeEx = "0.025 * safeZoneH";
        };
        class NameLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Preset name";
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.455 * safeZoneH + safeZoneY";
            w = "0.32 * safeZoneW";
            h = "0.03 * safeZoneH";
        };
        class Name: RscEdit
        {
            idc = IDC_AFCM_SIM_PSV_NAME;
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.49 * safeZoneH + safeZoneY";
            w = "0.32 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_BTN_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
        };
        class Save: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_PSV_SAVE;
            text = "Save";
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.545 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class Cancel: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_PSV_CANCEL;
            text = "Cancel";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.545 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "closeDialog 0;";
        };
    };
};

// ---------------------------------------------------------------------------------------------
// MCI (Mass Casualty Incident) Creator - a standalone, on-demand tool (not tied to placing a Zeus/
// Eden module first): pick a patient count, assign each patient its own Preset (or "random")
// independently, pick a spot on the real map by clicking it, then spawn the whole incident in one
// request. Callable directly (`call afcm_sim_ui_fnc_mciCreator_open;`) and bound to a real CBA
// keybind (default Ctrl+Shift+M, main/functions/fnc_registerMciCreatorKeybind.sqf) so it doesn't
// need the debug console in practice. Complements, doesn't replace, the module-based MCI Spawners
// (RscDisplayAFCM_SIM_LimbSelect's Presets flow / zeus+eden's AFCM_SIM_ModuleMciSpawner*) - those
// give every patient in a batch the SAME preset; this tool is for when they need to differ, per
// the "a HE shell hit a section, 3 are down, but with different injuries" case.
// ---------------------------------------------------------------------------------------------

#define IDD_AFCM_SIM_MCICREATOR 25605

#define IDC_AFCM_SIM_MC_TITLE           1
#define IDC_AFCM_SIM_MC_PATIENTCOUNT    10
#define IDC_AFCM_SIM_MC_CASUALTYTYPE    11
#define IDC_AFCM_SIM_MC_PATIENTLIST     12
#define IDC_AFCM_SIM_MC_PRESETLIST      13
#define IDC_AFCM_SIM_MC_ASSIGN          14
#define IDC_AFCM_SIM_MC_RANDOMIZEALL    15
#define IDC_AFCM_SIM_MC_LOCATIONSTATUS  16
#define IDC_AFCM_SIM_MC_CHOOSELOCATION  17
#define IDC_AFCM_SIM_MC_SAVEPRESET      18
#define IDC_AFCM_SIM_MC_LOADPRESET      19
#define IDC_AFCM_SIM_MC_SPAWN           20
#define IDC_AFCM_SIM_MC_CLOSE           21
#define IDC_AFCM_SIM_MC_MANAGESESSIONS  22
#define IDC_AFCM_SIM_MC_SESSIONNAME     23

// Two side-by-side listboxes: PatientList shows "Patient N — <spec>" rows (fnc_mciCreator_init.sqf
// populates it from AFCM_SIM_UI_mciPatientSpecs, a plain missionNamespace Array of spec strings,
// one per patient, "random" or a real Preset id — the actual working state of the incident being
// built); PresetList shows every available Preset ("Random" first, then built-in, then user).
// Assign applies PresetList's current selection onto PatientList's current selection
// (fnc_mciCreator_onAssign.sqf), re-populating just that one row's text.
class RscDisplayAFCM_SIM_MciCreator
{
    idd = IDD_AFCM_SIM_MCICREATOR;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_mciCreator_init;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.2 * safeZoneW + safeZoneX";
            y = "0.1075 * safeZoneH + safeZoneY";
            w = "0.6 * safeZoneW";
            h = "0.785 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_MC_TITLE;
            text = "MCI Creator";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.1275 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.032 * safeZoneH";
        };
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = -1;
            text = "Build a mass-casualty incident, then spawn it wherever you click on the map";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.1725 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.017 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.2025 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class PatientCountLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Patients";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.2175 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class PatientCount: RscCombo
        {
            idc = IDC_AFCM_SIM_MC_PATIENTCOUNT;
            x = "0.37 * safeZoneW + safeZoneX";
            y = "0.2175 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class CasualtyTypeLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Casualty Type";
            x = "0.52 * safeZoneW + safeZoneX";
            y = "0.2175 * safeZoneH + safeZoneY";
            w = "0.13 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class CasualtyType: RscCombo
        {
            idc = IDC_AFCM_SIM_MC_CASUALTYTYPE;
            x = "0.65 * safeZoneW + safeZoneX";
            y = "0.2175 * safeZoneH + safeZoneY";
            w = "0.13 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class SessionNameLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Session Name (optional)";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.2675 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        // Free-text label for this batch's Spawn Session (DESIGN.md § Spawn Sessions) - blank means
        // fnc_mciCreator_onSpawn.sqf/fnc_serverSpawnMci.sqf fall back to the same auto-generated
        // label ("AFCM MCI Spawner — N patients") used before this field existed.
        class SessionName: RscEdit
        {
            idc = IDC_AFCM_SIM_MC_SESSIONNAME;
            x = "0.4 * safeZoneW + safeZoneX";
            y = "0.2675 * safeZoneH + safeZoneY";
            w = "0.38 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_BTN_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
        };
        class PatientListLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Patients (select one)";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.3175 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.025 * safeZoneH";
        };
        class PresetListLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Available Presets";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.3175 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.025 * safeZoneH";
        };
        class PatientList: RscListBox
        {
            idc = IDC_AFCM_SIM_MC_PATIENTLIST;
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.3425 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.22 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_STATUS_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
            colorSelect[] = AFCM_SIM_COLOR_TEXT;
            colorSelectBackground[] = AFCM_SIM_COLOR_ACCENT_HOVER;
            sizeEx = "0.018 * safeZoneH";
        };
        class PresetList: RscListBox
        {
            idc = IDC_AFCM_SIM_MC_PRESETLIST;
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.3425 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.22 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_STATUS_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
            colorSelect[] = AFCM_SIM_COLOR_TEXT;
            colorSelectBackground[] = AFCM_SIM_COLOR_ACCENT_HOVER;
            sizeEx = "0.018 * safeZoneH";
        };
        class Assign: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_MC_ASSIGN;
            text = "Assign Selected Preset to Selected Patient";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.5725 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class RandomizeAll: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_RANDOMIZEALL;
            text = "Randomize All Patients";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.6125 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        // Text set dynamically (fnc_mciCreator_init.sqf/onMapConfirm.sqf) - "Location: not set yet"
        // until Choose Location on Map is used, then shows the picked position.
        class LocationStatus: RscText
        {
            idc = IDC_AFCM_SIM_MC_LOCATIONSTATUS;
            text = "Location: not set yet";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.6575 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.03 * safeZoneH";
            sizeEx = "0.018 * safeZoneH";
            colorText[] = AFCM_SIM_COLOR_TEXT_DIM;
        };
        class ChooseLocation: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_CHOOSELOCATION;
            text = "Choose Location on Map";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.6925 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class SavePreset: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_SAVEPRESET;
            text = "Save as MCI Preset";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.7325 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class LoadPreset: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_LOADPRESET;
            text = "Load MCI Preset";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.7325 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        // Opens the Session Manager (RscDisplayAFCM_SIM_SessionManager) - view/delete individual
        // Spawn Sessions (this MCI's own or anyone else's), or clear everything behind a
        // confirmation prompt. Wired via ButtonClick in fnc_mciCreator_init.sqf, same as every
        // other interactive button on this dialog.
        class ManageSessions: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_MANAGESESSIONS;
            text = "Manage Sessions";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.7775 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        // Disabled by fnc_mciCreator_init.sqf/fnc_mciCreator_onMapConfirm.sqf until a location has
        // actually been picked - spawning at objNull/undefined position would silently misplace
        // the whole incident.
        class Spawn: AFCM_SIM_RscButtonDanger
        {
            idc = IDC_AFCM_SIM_MC_SPAWN;
            text = "Spawn MCI";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.8225 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class Close: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_CLOSE;
            text = "Close";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.8225 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "closeDialog 0;";
        };
    };
};

#define IDD_AFCM_SIM_MAPPICKER 25606

#define IDC_AFCM_SIM_MAP_HINT    1
#define IDC_AFCM_SIM_MAP_MAP     10
#define IDC_AFCM_SIM_MAP_CONFIRM 11
#define IDC_AFCM_SIM_MAP_CANCEL  12

// Real interactive map-click position picker - a genuine RscMapControl (the same base class the
// vanilla in-mission map screen and countless custom marker-placement tools are built on), not a
// grid of buttons. Clicking it fires MouseButtonDown (real control event,
// `_this = [_control, _button, _x, _y, _shift, _ctrl, _alt]`); fnc_mapPicker_onClick.sqf converts
// the click to a world position via the real `ctrlMapScreenToWorld` command, stashes it, and drops
// a real local marker (`createMarkerLocal`) there so the pick is visible on the map itself, not
// just as text - moved on subsequent clicks, not recreated. Confirm hands the position back to the
// MCI Creator (fnc_mapPicker_onConfirm.sqf); the marker is cleaned up on close either way
// (fnc_mapPicker_cleanup.sqf, onUnload). Deliberately no branded panel behind the map itself - it
// would just obscure the thing being clicked on - only the hint text and buttons get the usual
// readability treatment (shadow=1, already on AFCM_SIM_RscLabel).
class RscDisplayAFCM_SIM_MapPicker
{
    idd = IDD_AFCM_SIM_MAPPICKER;
    movingEnable = 0;
    onLoad = "call afcm_sim_ui_fnc_mapPicker_init;";
    onUnload = "call afcm_sim_ui_fnc_mapPicker_cleanup;";

    class controls
    {
        class Hint: AFCM_SIM_RscLabel
        {
            idc = IDC_AFCM_SIM_MAP_HINT;
            text = "Click the map to choose the MCI's location, then Confirm.";
            x = "0.05 * safeZoneW + safeZoneX";
            y = "0.02 * safeZoneH + safeZoneY";
            w = "0.9 * safeZoneW";
            h = "0.03 * safeZoneH";
            sizeEx = "0.022 * safeZoneH";
        };
        class Map: RscMapControl
        {
            idc = IDC_AFCM_SIM_MAP_MAP;
            x = "0.05 * safeZoneW + safeZoneX";
            y = "0.06 * safeZoneH + safeZoneY";
            w = "0.9 * safeZoneW";
            h = "0.8 * safeZoneH";
            active = 1;
        };
        class Confirm: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_MAP_CONFIRM;
            text = "Confirm Location";
            x = "0.35 * safeZoneW + safeZoneX";
            y = "0.885 * safeZoneH + safeZoneY";
            w = "0.13 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class Cancel: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MAP_CANCEL;
            text = "Cancel";
            x = "0.52 * safeZoneW + safeZoneX";
            y = "0.885 * safeZoneH + safeZoneY";
            w = "0.13 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "closeDialog 0;";
        };
    };
};

#define IDD_AFCM_SIM_MCIPRESETLIBRARY 25607

#define IDC_AFCM_SIM_MPL_TITLE    1
#define IDC_AFCM_SIM_MPL_LIST     10
#define IDC_AFCM_SIM_MPL_LOAD     11
#define IDC_AFCM_SIM_MPL_DELETE   12
#define IDC_AFCM_SIM_MPL_EXPORT   13
#define IDC_AFCM_SIM_MPL_TEXT     14
#define IDC_AFCM_SIM_MPL_IMPORT   15
#define IDC_AFCM_SIM_MPL_CLOSE    16
#define IDC_AFCM_SIM_MPL_SUBTITLE 17

// Same shape as RscDisplayAFCM_SIM_PresetLibrary, for MCI presets instead of single-injury ones -
// "Load" (not "Apply") replaces the MCI Creator's whole patient list with the selected MCI
// preset's patientSpecs (fnc_mciPresetLibrary_onLoad.sqf), rather than applying anything to a unit
// directly - MCI presets are a template for the Creator to build from, not something spawned
// straight from here.
class RscDisplayAFCM_SIM_MciPresetLibrary
{
    idd = IDD_AFCM_SIM_MCIPRESETLIBRARY;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_mciPresetLibrary_init;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.25 * safeZoneW + safeZoneX";
            y = "0.21 * safeZoneH + safeZoneY";
            w = "0.5 * safeZoneW";
            h = "0.58 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_MPL_TITLE;
            text = "MCI Preset Library";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.23 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.03 * safeZoneH";
        };
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = IDC_AFCM_SIM_MPL_SUBTITLE;
            text = "Load a saved incident into the MCI Creator, or export/import one below";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.268 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.017 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.3 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class List: RscListBox
        {
            idc = IDC_AFCM_SIM_MPL_LIST;
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.31 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.28 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_STATUS_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
            colorSelect[] = AFCM_SIM_COLOR_TEXT;
            colorSelectBackground[] = AFCM_SIM_COLOR_ACCENT_HOVER;
            sizeEx = "0.019 * safeZoneH";
        };
        class Load: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_MPL_LOAD;
            text = "Load";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.6 * safeZoneH + safeZoneY";
            w = "0.146 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Delete: AFCM_SIM_RscButtonDanger
        {
            idc = IDC_AFCM_SIM_MPL_DELETE;
            text = "Delete";
            x = "0.427 * safeZoneW + safeZoneX";
            y = "0.6 * safeZoneH + safeZoneY";
            w = "0.146 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Export: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MPL_EXPORT;
            text = "Export ↓";
            x = "0.584 * safeZoneW + safeZoneX";
            y = "0.6 * safeZoneH + safeZoneY";
            w = "0.146 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class TextLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "MCI preset string (select all, Ctrl+C to copy — Ctrl+V to paste, then Import)";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.65 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.016 * safeZoneH";
        };
        class Text: RscEdit
        {
            idc = IDC_AFCM_SIM_MPL_TEXT;
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.675 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_BTN_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
        };
        class Import: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_MPL_IMPORT;
            text = "Import ↑";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.725 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Close: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MPL_CLOSE;
            text = "Close";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.725 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.04 * safeZoneH";
            action = "closeDialog 0;";
        };
    };
};

#define IDD_AFCM_SIM_MCIPRESETSAVE 25608

#define IDC_AFCM_SIM_MPS_TITLE  1
#define IDC_AFCM_SIM_MPS_NAME   10
#define IDC_AFCM_SIM_MPS_SAVE   11
#define IDC_AFCM_SIM_MPS_CANCEL 12

// Name prompt for saving the MCI Creator's current patient list as a reusable MCI preset - same
// shape as RscDisplayAFCM_SIM_PresetSave.
class RscDisplayAFCM_SIM_MciPresetSave
{
    idd = IDD_AFCM_SIM_MCIPRESETSAVE;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_mciPresetSave_init;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.39 * safeZoneH + safeZoneY";
            w = "0.36 * safeZoneW";
            h = "0.22 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_MPS_TITLE;
            text = "Save MCI Preset";
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.41 * safeZoneH + safeZoneY";
            w = "0.32 * safeZoneW";
            h = "0.035 * safeZoneH";
            sizeEx = "0.025 * safeZoneH";
        };
        class NameLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Incident name";
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.455 * safeZoneH + safeZoneY";
            w = "0.32 * safeZoneW";
            h = "0.03 * safeZoneH";
        };
        class Name: RscEdit
        {
            idc = IDC_AFCM_SIM_MPS_NAME;
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.49 * safeZoneH + safeZoneY";
            w = "0.32 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_BTN_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
        };
        class Save: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_MPS_SAVE;
            text = "Save";
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.545 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class Cancel: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MPS_CANCEL;
            text = "Cancel";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.545 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "closeDialog 0;";
        };
    };
};

// ---------------------------------------------------------------------------------------------
// Spawn Sessions - every batch of patients spawned together (a Zeus/Eden MCI Spawner, an MCI
// Creator incident, an AFCM MASCAL Zone) is grouped into one named session
// (afcm_sim_spawner_fnc_spawnPatient/newSessionId), separate from single spawns which each get
// their own one-patient session automatically. The Session Manager lists them and can delete just
// one - e.g. two medics each working their own MCI at once, one gets cleared, the other's patients
// stay untouched - as well as "Clear All Sessions" (the old global clearAllPatients, now gated
// behind a real confirmation prompt since it's the highest-blast-radius action in the mod).
// ---------------------------------------------------------------------------------------------

#define IDD_AFCM_SIM_SESSIONMANAGER 25609

#define IDC_AFCM_SIM_SM_TITLE      1
#define IDC_AFCM_SIM_SM_LIST       10
#define IDC_AFCM_SIM_SM_DELETE     11
#define IDC_AFCM_SIM_SM_CLEARALL   12
#define IDC_AFCM_SIM_SM_CLOSE      13

// Lists every active session ("Label — N patients, spawned Xm ago", fnc_sessionManager_populateList.sqf),
// each row's real session id stashed via `lbSetData` (same pattern as the Preset Library). Delete
// Session removes just the selected one (afcm_sim_spawner_fnc_serverDeleteSession); Clear All
// Sessions opens the generic Confirm dialog before actually calling
// afcm_sim_spawner_fnc_clearAllPatients (fnc_sessionManager_onClearAll.sqf) - deliberately the only
// destructive action in this whole UI kit that's gated behind a confirmation, since it's the one
// action with no per-session scoping at all.
class RscDisplayAFCM_SIM_SessionManager
{
    idd = IDD_AFCM_SIM_SESSIONMANAGER;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_sessionManager_init;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.25 * safeZoneW + safeZoneX";
            y = "0.23 * safeZoneH + safeZoneY";
            w = "0.5 * safeZoneW";
            h = "0.543 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_SM_TITLE;
            text = "Session Manager";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.25 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.03 * safeZoneH";
        };
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = -1;
            text = "Delete removes just one session's patients - Clear All removes every patient";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.288 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.017 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.32 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class List: RscListBox
        {
            idc = IDC_AFCM_SIM_SM_LIST;
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.33 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.28 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_STATUS_BG;
            colorText[] = AFCM_SIM_COLOR_TEXT;
            colorSelect[] = AFCM_SIM_COLOR_TEXT;
            colorSelectBackground[] = AFCM_SIM_COLOR_ACCENT_HOVER;
            sizeEx = "0.019 * safeZoneH";
        };
        // Disabled until a session is selected (fnc_sessionManager_onSelect.sqf).
        class DeleteSession: AFCM_SIM_RscButtonDanger
        {
            idc = IDC_AFCM_SIM_SM_DELETE;
            text = "Delete Selected Session";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.62 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class ClearAll: AFCM_SIM_RscButtonDanger
        {
            idc = IDC_AFCM_SIM_SM_CLEARALL;
            text = "Clear All Sessions";
            x = "0.27 * safeZoneW + safeZoneX";
            y = "0.665 * safeZoneH + safeZoneY";
            w = "0.46 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Close: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_SM_CLOSE;
            text = "Close";
            x = "0.425 * safeZoneW + safeZoneX";
            y = "0.71 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.038 * safeZoneH";
            action = "closeDialog 0;";
        };
    };
};

#define IDD_AFCM_SIM_CONFIRM 25610

#define IDC_AFCM_SIM_CONFIRM_TITLE   1
#define IDC_AFCM_SIM_CONFIRM_MESSAGE 10
#define IDC_AFCM_SIM_CONFIRM_YES     11
#define IDC_AFCM_SIM_CONFIRM_NO      12

// Generic reusable Yes/No confirmation, not specific to sessions - any future destructive action
// in this addon can reuse it via afcm_sim_ui_fnc_confirmDialog_open (message, a Code to run on
// Yes). Currently only used by the Session Manager's Clear All Sessions button
// (fnc_sessionManager_onClearAll.sqf). No is a plain `action = "closeDialog 0;"`, same as every
// other Cancel-style button in this addon.
class RscDisplayAFCM_SIM_ConfirmDialog
{
    idd = IDD_AFCM_SIM_CONFIRM;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_confirmDialog_init;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.39 * safeZoneH + safeZoneY";
            w = "0.36 * safeZoneW";
            h = "0.22 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_CONFIRM_TITLE;
            text = "Confirm";
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.41 * safeZoneH + safeZoneY";
            w = "0.32 * safeZoneW";
            h = "0.035 * safeZoneH";
            sizeEx = "0.025 * safeZoneH";
        };
        // Text set dynamically (fnc_confirmDialog_init.sqf, from AFCM_SIM_UI_confirmMessage).
        class Message: AFCM_SIM_RscLabel
        {
            idc = IDC_AFCM_SIM_CONFIRM_MESSAGE;
            text = "";
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.455 * safeZoneH + safeZoneY";
            w = "0.32 * safeZoneW";
            h = "0.075 * safeZoneH";
            sizeEx = "0.019 * safeZoneH";
        };
        class Yes: AFCM_SIM_RscButtonDanger
        {
            idc = IDC_AFCM_SIM_CONFIRM_YES;
            text = "Yes";
            x = "0.34 * safeZoneW + safeZoneX";
            y = "0.545 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class No: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_CONFIRM_NO;
            text = "No";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.545 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "closeDialog 0;";
        };
    };
};

#define IDD_AFCM_SIM_INJURYAUTHOR 25611

#define IDC_AFCM_SIM_IA_TITLE           1
#define IDC_AFCM_SIM_IA_NAV_HEAD        10
#define IDC_AFCM_SIM_IA_NAV_CHEST       11
#define IDC_AFCM_SIM_IA_NAV_ARM_L       12
#define IDC_AFCM_SIM_IA_NAV_ARM_R       13
#define IDC_AFCM_SIM_IA_NAV_LEG_L       14
#define IDC_AFCM_SIM_IA_NAV_LEG_R       15
#define IDC_AFCM_SIM_IA_LIMBLABEL       16
#define IDC_AFCM_SIM_IA_WOUNDTYPE       20
#define IDC_AFCM_SIM_IA_SEVERITY        21
#define IDC_AFCM_SIM_IA_BLEEDING        22
#define IDC_AFCM_SIM_IA_FRACTURELABEL   23
#define IDC_AFCM_SIM_IA_FRACTURE        24
#define IDC_AFCM_SIM_IA_PNEUMOLABEL     25
#define IDC_AFCM_SIM_IA_PNEUMOTHORAX    26
#define IDC_AFCM_SIM_IA_AIRWAYLABEL     27
#define IDC_AFCM_SIM_IA_AIRWAY          28
#define IDC_AFCM_SIM_IA_CARDIACLABEL    29
#define IDC_AFCM_SIM_IA_CARDIACSTATE    30
#define IDC_AFCM_SIM_IA_STATUS          35
#define IDC_AFCM_SIM_IA_APPLY           40
#define IDC_AFCM_SIM_IA_RESETLIMB       41
#define IDC_AFCM_SIM_IA_SAVEPRESET      42
#define IDC_AFCM_SIM_IA_LOADPRESET      43
#define IDC_AFCM_SIM_IA_EXPORT          44
#define IDC_AFCM_SIM_IA_IMPORT          45
#define IDC_AFCM_SIM_IA_IMPORTEXPORTTEXT 46
#define IDC_AFCM_SIM_IA_CLEARALL        47
#define IDC_AFCM_SIM_IA_RANDOMDAMAGE    48
#define IDC_AFCM_SIM_IA_INJURYLEVEL     49
#define IDC_AFCM_SIM_IA_RESETPATIENT    50
#define IDC_AFCM_SIM_IA_CHOOSELOCATION  51
#define IDC_AFCM_SIM_IA_LOCATIONSTATUS  52
#define IDC_AFCM_SIM_IA_CLOSE           53

// Replaces RscDisplayAFCM_SIM_LimbSelect + RscDisplayAFCM_SIM_InjuryEditor (both retired, IDD
// 25601/25602 not reused) with one dialog: a persistent left-side limb navbar next to a single
// injury-configuration form, so switching limbs never leaves the dialog - the old flow's "go back
// in and out constantly" problem (select limb(s) on one screen, configure the SAME shared wound for
// all of them on a second screen, repeat per limb to get different wounds on different limbs).
//
// Two modes, both real, sharing every control below - only Apply's behaviour and which of
// ResetPatient/ChooseLocation+LocationStatus is shown differ (fnc_injuryAuthor_init.sqf):
//  - Edit an already-spawned patient (AFCM_SIM_UI_targetUnit set, "AFCM: Edit Injuries" scroll
//    action or the Zeus AFCM_SIM_ModuleEditInjuries drag-onto-unit flow) - the staging form
//    pre-loads that unit's current injuries/KAT extras (fnc_injuryAuthor_loadFromUnit.sqf), Apply
//    commits the whole staged set to it in one afcm_sim_scenario_fnc_serverApplyPreset call,
//    ResetPatient (danger-red) is shown.
//  - Author a brand-new patient with no live unit yet (Ctrl+Shift+I keybind,
//    fnc_registerInjuryAuthorKeybind.sqf, afcm_sim_main) - staging starts empty (or restored from
//    the last-used set, afcm_sim_rememberLastInjuries CBA setting), Apply reads "Apply & Spawn
//    Patient" and calls afcm_sim_spawner_fnc_spawnPatient instead, disabled until a spawn location
//    is chosen via ChooseLocation (RscDisplayAFCM_SIM_MapPicker, reused as-is - stacks on top,
//    same "disabled until location chosen" UX as the MCI Creator's own Spawn button) - LocationStatus
//    shows what's picked so far.
//
// Staged state (fnc_injuryAuthor_setActiveLimb.sqf/commitActiveLimbForm.sqf) lives in
// AFCM_SIM_UI_stagedInjuries (Array of [limb, woundType, severity, bleeding, bleedRate] - the same
// shape fnc_exportPatientState.sqf/fnc_buildInjury.sqf already use) and AFCM_SIM_UI_stagedKatExtras
// (`[fractures<6>, pneumothoraxType, airwayType, cardiacRhythm]`) - switching the active limb via
// the navbar flushes whatever's on screen into these arrays first, then repopulates the form from
// whatever's already staged for the newly-active limb (or defaults/"None" if nothing's staged yet).
// WoundType's new "None" option (index 0) means "no injury on this limb" - removes that limb's
// entry from AFCM_SIM_UI_stagedInjuries entirely rather than ever being written into a tuple that
// reaches afcm_sim_scenario_fnc_buildInjury, which has never had a "none" woundType.
//
// Bleeding is a 5-option severity combo now (None/Light/Medium/Heavy/Severe), not the old
// checkbox - real, chosen bleedRate instead of a hidden random roll. Grounded against
// fnc_medical_applyAceStyleInjuryLocal.sqf's own bleedRate->ACE-wound-size bucketing (0.15/0.3
// thresholds, only 3 real sizes exist) when picking the 4 non-None rate values - see
// fnc_injuryAuthor_init.sqf's own comment for the exact mapping.
//
// Fracture/Pneumothorax/Airway/CardiacState gating is the exact same arm-leg/chest/head rules the
// old InjuryEditor used (fnc_injuryAuthor_setActiveLimb.sqf), just re-evaluated on navbar switch
// instead of once against a multi-select. Same reasoning for the live status readout
// (fnc_injuryAuthor_refreshState.sqf, edit-mode only) - keyed to whichever ONE limb is active now,
// fixing the old dialog's "always shows the first of possibly several selected limbs" limitation.
//
// No injury-removal primitive exists anywhere in this mod (DESIGN.md, confirmed) - if edit-mode
// pre-loads a live unit's current wounds and one gets un-staged (set back to "None") then Apply is
// clicked, the wound already live on the patient is NOT removed, only never-re-applied. Real
// limitation, not something this dialog can fix on its own.
class RscDisplayAFCM_SIM_InjuryAuthor
{
    idd = IDD_AFCM_SIM_INJURYAUTHOR;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_injuryAuthor_init;";
    onUnload = "call afcm_sim_ui_fnc_injuryAuthor_cleanup;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.20 * safeZoneW + safeZoneX";
            y = "0.08 * safeZoneH + safeZoneY";
            w = "0.60 * safeZoneW";
            h = "0.81 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_IA_TITLE;
            text = "AFCM-Simulator — Injury Author";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.095 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.035 * safeZoneH";
            sizeEx = "0.027 * safeZoneH";
        };
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = -1;
            text = "Pick a region on the left, configure it, repeat - nothing is applied until you commit";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.128 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.022 * safeZoneH";
            sizeEx = "0.015 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.155 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        // Left-side navbar - a plain vertical list (Head/Chest/L Arm/R Arm/L Leg/R Leg), not the
        // old dialog's 2D "rough body" button grid, since that layout doesn't fit a narrow single
        // column - and a straight top-to-bottom list is literally "go down the body limb list",
        // the exact request this replaces the old back-and-forth flow with. Recolored 3 ways
        // (unselected/has-staged-injury/active) by fnc_injuryAuthor_refreshNavbar.sqf.
        class NavHead: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_NAV_HEAD;
            text = "Head";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.170 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""head""] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;";
        };
        class NavChest: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_NAV_CHEST;
            text = "Chest";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.221 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""chest""] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;";
        };
        class NavArmLeft: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_NAV_ARM_L;
            text = "Left Arm";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.272 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftArm""] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;";
        };
        class NavArmRight: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_NAV_ARM_R;
            text = "Right Arm";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.323 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightArm""] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;";
        };
        class NavLegLeft: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_NAV_LEG_L;
            text = "Left Leg";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.374 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftLeg""] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;";
        };
        class NavLegRight: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_NAV_LEG_R;
            text = "Right Leg";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.425 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightLeg""] call afcm_sim_ui_fnc_injuryAuthor_onNavClick;";
        };
        // Text/color set dynamically (fnc_injuryAuthor_setActiveLimb.sqf) - shows which limb the
        // form on the right is currently editing.
        class LimbLabel: AFCM_SIM_RscSubtitle
        {
            idc = IDC_AFCM_SIM_IA_LIMBLABEL;
            text = "Editing";
            x = "0.40 * safeZoneW + safeZoneX";
            y = "0.170 * safeZoneH + safeZoneY";
            w = "0.38 * safeZoneW";
            h = "0.03 * safeZoneH";
            sizeEx = "0.02 * safeZoneH";
        };
        class WoundTypeLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Wound Type";
            x = "0.40 * safeZoneW + safeZoneX";
            y = "0.208 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class WoundType: RscCombo
        {
            idc = IDC_AFCM_SIM_IA_WOUNDTYPE;
            x = "0.56 * safeZoneW + safeZoneX";
            y = "0.208 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class SeverityLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Severity";
            x = "0.40 * safeZoneW + safeZoneX";
            y = "0.248 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class Severity: RscCombo
        {
            idc = IDC_AFCM_SIM_IA_SEVERITY;
            x = "0.56 * safeZoneW + safeZoneX";
            y = "0.248 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        // Was a plain Bleeding checkbox - now a 5-option severity combo (None/Light/Medium/Heavy/
        // Severe) so the controller picks a real bleedRate instead of a hidden random roll -
        // fnc_injuryAuthor_init.sqf populates the exact values.
        class BleedingLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Bleeding";
            x = "0.40 * safeZoneW + safeZoneX";
            y = "0.288 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class Bleeding: RscCombo
        {
            idc = IDC_AFCM_SIM_IA_BLEEDING;
            x = "0.56 * safeZoneW + safeZoneX";
            y = "0.288 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        // Shared (ACE + KAT) - see the old RscDisplayAFCM_SIM_InjuryEditor's own comment for the
        // full real-source grounding, unchanged here beyond being keyed off the active nav limb.
        class CardiacLabel: AFCM_SIM_RscLabel
        {
            idc = IDC_AFCM_SIM_IA_CARDIACLABEL;
            text = "Cardiac State";
            x = "0.40 * safeZoneW + safeZoneX";
            y = "0.328 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class CardiacState: RscCombo
        {
            idc = IDC_AFCM_SIM_IA_CARDIACSTATE;
            x = "0.56 * safeZoneW + safeZoneX";
            y = "0.328 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class FractureLabel: AFCM_SIM_RscLabel
        {
            idc = IDC_AFCM_SIM_IA_FRACTURELABEL;
            text = "Fracture (Arms/Legs)";
            x = "0.40 * safeZoneW + safeZoneX";
            y = "0.368 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class Fracture: RscCombo
        {
            idc = IDC_AFCM_SIM_IA_FRACTURE;
            x = "0.56 * safeZoneW + safeZoneX";
            y = "0.368 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class PneumoLabel: AFCM_SIM_RscLabel
        {
            idc = IDC_AFCM_SIM_IA_PNEUMOLABEL;
            text = "Pneumothorax (KAT)";
            x = "0.40 * safeZoneW + safeZoneX";
            y = "0.408 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class Pneumothorax: RscCombo
        {
            idc = IDC_AFCM_SIM_IA_PNEUMOTHORAX;
            x = "0.56 * safeZoneW + safeZoneX";
            y = "0.408 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class AirwayLabel: AFCM_SIM_RscLabel
        {
            idc = IDC_AFCM_SIM_IA_AIRWAYLABEL;
            text = "Airway (Head)";
            x = "0.40 * safeZoneW + safeZoneX";
            y = "0.448 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class Airway: RscCombo
        {
            idc = IDC_AFCM_SIM_IA_AIRWAY;
            x = "0.56 * safeZoneW + safeZoneX";
            y = "0.448 * safeZoneH + safeZoneY";
            w = "0.22 * safeZoneW";
            h = "0.036 * safeZoneH";
        };
        class StatusBg: AFCM_SIM_Panel
        {
            x = "0.215 * safeZoneW + safeZoneX";
            y = "0.485 * safeZoneH + safeZoneY";
            w = "0.575 * safeZoneW";
            h = "0.09 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_STATUS_BG;
        };
        // Live medical state (edit mode only, afcm_sim_fnc_backend_getState) - now genuinely keyed
        // to whichever ONE limb is active in the navbar, fixing the old dialog's "always shows the
        // first of possibly several selected limbs" limitation. Author-new-patient mode shows a
        // static placeholder instead (fnc_injuryAuthor_init.sqf) - no live unit to query yet.
        class StatusText: RscText
        {
            idc = IDC_AFCM_SIM_IA_STATUS;
            text = "";
            x = "0.225 * safeZoneW + safeZoneX";
            y = "0.490 * safeZoneH + safeZoneY";
            w = "0.555 * safeZoneW";
            h = "0.08 * safeZoneH";
            sizeEx = "0.019 * safeZoneH";
            colorText[] = AFCM_SIM_COLOR_TEXT_DIM;
        };
        // Text/mode set dynamically - "Apply" (edit mode, commits to AFCM_SIM_UI_targetUnit) or
        // "Apply & Spawn Patient" (author-new-patient mode, disabled until ChooseLocation below is
        // used, same "disabled until location chosen" pattern as the MCI Creator's own Spawn).
        class Apply: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_IA_APPLY;
            text = "Apply";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.585 * safeZoneH + safeZoneY";
            w = "0.275 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Local-only - clears just the active limb's staged entry/form, never touches a live unit.
        class ResetLimb: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_RESETLIMB;
            text = "Reset Limb";
            x = "0.505 * safeZoneW + safeZoneX";
            y = "0.585 * safeZoneH + safeZoneY";
            w = "0.275 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Saves the active limb's current wound as a new single-injury user preset - same
        // base-injuries-only scope the old dialog's Save as Preset had (Preset schema has no slot
        // for KAT extras).
        class SavePreset: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_SAVEPRESET;
            text = "Save as Preset";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.633 * safeZoneH + safeZoneY";
            w = "0.275 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Opens the Preset Library in a new third "staging" mode (AFCM_SIM_UI_targetStaging) -
        // loads the selected preset's injuries/katExtras straight into this dialog's staged arrays
        // instead of remoteExec'ing to a live unit.
        class LoadPreset: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_LOADPRESET;
            text = "Load Preset";
            x = "0.505 * safeZoneW + safeZoneX";
            y = "0.633 * safeZoneH + safeZoneY";
            w = "0.275 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Exports the whole staged set (afcm_sim_scenario_fnc_exportInjuries) to the text field
        // below + the OS clipboard.
        class Export: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_EXPORT;
            text = "Export";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.681 * safeZoneH + safeZoneY";
            w = "0.275 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Parses whatever's in the text field below (afcm_sim_scenario_fnc_parseExportedPreset,
        // accepts either real export shape) and overwrites the whole staged set with it.
        class Import: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_IMPORT;
            text = "Import";
            x = "0.505 * safeZoneW + safeZoneX";
            y = "0.681 * safeZoneH + safeZoneY";
            w = "0.275 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class ImportExportText: RscEdit
        {
            idc = IDC_AFCM_SIM_IA_IMPORTEXPORTTEXT;
            text = "";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.729 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        // Wipes the entire staged set (every limb + KAT extras) in one click, not just the active
        // limb (ResetLimb above) - also clears the remembered last-used set if
        // afcm_sim_rememberLastInjuries is on.
        class ClearAll: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_CLEARALL;
            text = "Clear All";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.779 * safeZoneH + safeZoneY";
            w = "0.175 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Rolls a fresh randomized injury set at the level picked in InjuryLevel
        // (afcm_sim_scenario_fnc_randomizeInjuries) and loads it into the staged arrays - same
        // "overwrite staged state" pattern as Import/Load Preset, just generated instead of read.
        class RandomDamage: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_RANDOMDAMAGE;
            text = "Random Damage";
            x = "0.405 * safeZoneW + safeZoneX";
            y = "0.779 * safeZoneH + safeZoneY";
            w = "0.175 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class InjuryLevel: RscCombo
        {
            idc = IDC_AFCM_SIM_IA_INJURYLEVEL;
            x = "0.59 * safeZoneW + safeZoneX";
            y = "0.779 * safeZoneH + safeZoneY";
            w = "0.19 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Edit mode only - the real full-unit reset (fullHeal + re-lock unconscious), same danger
        // style the old LimbSelect's Reset Patient had. Hidden entirely in author-new-patient mode.
        class ResetPatient: AFCM_SIM_RscButtonDanger
        {
            idc = IDC_AFCM_SIM_IA_RESETPATIENT;
            text = "Reset Patient";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.827 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Author-new-patient mode only - occupies the same row/space as ResetPatient above (only
        // one set ctrlShow'n at a time, fnc_injuryAuthor_init.sqf). Opens the Map Picker on top of
        // this dialog, same reused component/stacking pattern the MCI Creator's own "Choose
        // Location on Map" uses.
        class ChooseLocation: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_CHOOSELOCATION;
            text = "Choose Location on Map";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.827 * safeZoneH + safeZoneY";
            w = "0.19 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class LocationStatus: RscText
        {
            idc = IDC_AFCM_SIM_IA_LOCATIONSTATUS;
            text = "Location: not set yet";
            x = "0.415 * safeZoneW + safeZoneX";
            y = "0.827 * safeZoneH + safeZoneY";
            w = "0.20 * safeZoneW";
            h = "0.045 * safeZoneH";
            sizeEx = "0.017 * safeZoneH";
            colorText[] = AFCM_SIM_COLOR_TEXT_DIM;
        };
        class Close: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IA_CLOSE;
            text = "Close";
            x = "0.62 * safeZoneW + safeZoneX";
            y = "0.827 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0.1, 0.1, 0.11, 0.75};
            action = "closeDialog 0;";
        };
    };
};

// Custom AFCM-branded toast - a passive, non-interactive HUD overlay (RscTitles, shown via cutRsc),
// not another RscDisplay dialog. Deliberately NOT createDialog-based: createDialog opens a real
// interactive display competing for input focus, which would fight with (or outright break) the
// Zeus interface or whatever dialog the viewer already has open. cutRsc's whole purpose is a
// non-modal overlay layer that sits on top without stealing focus - real, confirmed vanilla
// mechanism (community.bistudio.com/wiki/cutRsc): `layer cutRsc [name, effect, speed,
// drawOverHUD]`, name referencing an RscTitles-defined class exactly like an RscDisplay idd does.
// `duration` (below) is a real RscTitles-only attribute that auto-hides the layer on its own - no
// manual close timer needed. Shown by afcm_sim_ui_fnc_showToast (a generic two-line title/body
// helper); afcm_sim_ui_fnc_notifySessionResolved (Medical Tent completion) is its first caller, but
// any future AFCM event can reuse it the same way ConfirmDialog is reused for destructive actions.
#define IDC_AFCM_SIM_TOAST_TITLE 1
#define IDC_AFCM_SIM_TOAST_BODY  2

class RscTitles
{
    class RscDisplayAFCM_SIM_Toast
    {
        idd = -1;
        duration = 8;
        fadeIn = 0.35;
        fadeOut = 0.75;
        onLoad = "(_this select 0) call afcm_sim_ui_fnc_toast_init;";
        class controls
        {
            class Panel: AFCM_SIM_Panel
            {
                x = "0.32 * safeZoneW + safeZoneX";
                y = "0.06 * safeZoneH + safeZoneY";
                w = "0.36 * safeZoneW";
                h = "0.09 * safeZoneH";
            };
            class AccentBar: AFCM_SIM_AccentBar
            {
                x = "0.32 * safeZoneW + safeZoneX";
                y = "0.06 * safeZoneH + safeZoneY";
                w = "0.36 * safeZoneW";
                h = "0.0025 * safeZoneH";
            };
            // Text set dynamically (fnc_toast_init.sqf, from AFCM_SIM_UI_toastTitle/Body).
            class Title: AFCM_SIM_RscTitle
            {
                idc = IDC_AFCM_SIM_TOAST_TITLE;
                text = "";
                x = "0.335 * safeZoneW + safeZoneX";
                y = "0.0725 * safeZoneH + safeZoneY";
                w = "0.35 * safeZoneW";
                h = "0.03 * safeZoneH";
                sizeEx = "0.022 * safeZoneH";
            };
            class Body: AFCM_SIM_RscLabel
            {
                idc = IDC_AFCM_SIM_TOAST_BODY;
                text = "";
                x = "0.335 * safeZoneW + safeZoneX";
                y = "0.1025 * safeZoneH + safeZoneY";
                w = "0.35 * safeZoneW";
                h = "0.04 * safeZoneH";
                sizeEx = "0.018 * safeZoneH";
                colorText[] = AFCM_SIM_COLOR_TEXT_DIM;
            };
        };
    };
};
