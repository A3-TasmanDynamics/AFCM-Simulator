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
        class LimbSelect
        {
            file = "\afcm_sim\addons\ui\functions";
            class limbSelect_open { file = "\afcm_sim\addons\ui\functions\fnc_limbSelect_open.sqf"; };
            class limbSelect_init { file = "\afcm_sim\addons\ui\functions\fnc_limbSelect_init.sqf"; };
            class limbSelect_onLimbToggle { file = "\afcm_sim\addons\ui\functions\fnc_limbSelect_onLimbToggle.sqf"; };
            class limbSelect_refreshButtons { file = "\afcm_sim\addons\ui\functions\fnc_limbSelect_refreshButtons.sqf"; };
            class limbSelect_onApplyTrauma { file = "\afcm_sim\addons\ui\functions\fnc_limbSelect_onApplyTrauma.sqf"; };
            class limbSelect_onResetPatient { file = "\afcm_sim\addons\ui\functions\fnc_limbSelect_onResetPatient.sqf"; };
            class limbSelect_onOpenPresets { file = "\afcm_sim\addons\ui\functions\fnc_limbSelect_onOpenPresets.sqf"; };
        };
        class InjuryEditor
        {
            file = "\afcm_sim\addons\ui\functions";
            class injuryEditor_open { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_open.sqf"; };
            class injuryEditor_init { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_init.sqf"; };
            class injuryEditor_cleanup { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_cleanup.sqf"; };
            class injuryEditor_onApply { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_onApply.sqf"; };
            class injuryEditor_onBack { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_onBack.sqf"; };
            class injuryEditor_onReset { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_onReset.sqf"; };
            class injuryEditor_refreshState { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_refreshState.sqf"; };
            class injuryEditor_onSavePreset { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_onSavePreset.sqf"; };
            class addInjuryEditorAction { file = "\afcm_sim\addons\ui\functions\fnc_addInjuryEditorAction.sqf"; };
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
#define AFCM_SIM_COLOR_BTN_FOCUS      {0.757, 0.153, 0.176, 0.45}
#define AFCM_SIM_COLOR_DANGER_BG      {0.42, 0.1, 0.09, 0.9}
#define AFCM_SIM_COLOR_DANGER_HOVER   {0.65, 0.13, 0.11, 1}
#define AFCM_SIM_COLOR_STATUS_BG      {0.02, 0.02, 0.025, 0.72}

class RscText;
class RscButton;
class RscCombo;
class RscCheckBox;
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
// "Right Leg" button in the reported screenshot).
class AFCM_SIM_RscButton: RscButton
{
    colorBackground[] = AFCM_SIM_COLOR_BTN_BG;
    colorBackgroundActive[] = AFCM_SIM_COLOR_ACCENT_HOVER;
    colorBackgroundDisabled[] = AFCM_SIM_COLOR_BTN_DISABLED;
    colorFocused[] = AFCM_SIM_COLOR_BTN_FOCUS;
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

#define IDD_AFCM_SIM_LIMBSELECT 25601

#define IDC_AFCM_SIM_LS_TITLE       1
#define IDC_AFCM_SIM_LS_HEAD        10
#define IDC_AFCM_SIM_LS_CHEST       11
#define IDC_AFCM_SIM_LS_ARM_L       12
#define IDC_AFCM_SIM_LS_ARM_R       13
#define IDC_AFCM_SIM_LS_LEG_L       14
#define IDC_AFCM_SIM_LS_LEG_R       15
#define IDC_AFCM_SIM_LS_CLOSE       16
#define IDC_AFCM_SIM_LS_RESET       17
#define IDC_AFCM_SIM_LS_PRESETS     18
#define IDC_AFCM_SIM_LS_APPLYTRAUMA 19

// First real screen for "Selectable Body Limbs" (DESIGN.md §5). Still a plain button-per-limb
// layout, not a clickable body silhouette — a hit-tested silhouette needs a custom texture asset
// (hit-region image) that doesn't exist yet. Sits on a branded panel backdrop (AFCM_SIM_Panel +
// AFCM_SIM_AccentBar), true-centered on screen — panel width/height are chosen so
// `x = (1 - w) / 2` and `y = (1 - h) / 2` land the whole thing dead-center of the safe zone
// regardless of resolution/aspect ratio (safeZoneW/H/X/Y are themselves already resolution-aware).
//
// 6 buttons, a direct 1:1 match to ACE3's own real body parts (DESIGN.md §4.1 / INJURY_CODES.md
// §1) — deliberately kept this simple rather than a finer anatomical breakdown that was built and
// then reverted. Toggle buttons now (fnc_limbSelect_onLimbToggle.sqf), not one-click-navigate -
// each click adds/removes that limb from AFCM_SIM_UI_selectedLimbs and recolors itself via
// `ctrlSetBackgroundColor` (fnc_limbSelect_refreshButtons.sqf) to show it's selected. Arranged in
// a rough body layout: head at top, arms either side of chest, legs at the bottom, then a
// full-width "Apply Trauma to Selected Limb(s)" button (opens the injury editor for the whole
// selection at once, fnc_limbSelect_onApplyTrauma.sqf - disabled with an explanation until at
// least one limb is toggled), then Presets (opens RscDisplayAFCM_SIM_PresetLibrary), then Reset
// Patient (the real, full-unit afcm_sim_fnc_backend_reset dispatch - moved here from the injury
// editor, which now has its own much lighter, purely-local "Reset Limb", see
// RscDisplayAFCM_SIM_InjuryEditor below), then Close. Decorative controls (Panel/Subtitle/
// AccentBar) are idc=-1 and never read by script; only the button/title IDCs above need to stay
// in sync with fnc_limbSelect_*.sqf.
class RscDisplayAFCM_SIM_LimbSelect
{
    idd = IDD_AFCM_SIM_LIMBSELECT;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_limbSelect_init;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.28 * safeZoneW + safeZoneX";
            y = "0.25 * safeZoneH + safeZoneY";
            w = "0.44 * safeZoneW";
            h = "0.505 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_LS_TITLE;
            text = "Select Injured Region";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.27 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.032 * safeZoneH";
        };
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = -1;
            text = "Click one or more body regions, then apply the same trauma to all of them";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.308 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.017 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.34 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class Head: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_HEAD;
            text = "Head";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.365 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""head""] call afcm_sim_ui_fnc_limbSelect_onLimbToggle;";
        };
        class ArmLeft: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_ARM_L;
            text = "Left Arm";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.42 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftArm""] call afcm_sim_ui_fnc_limbSelect_onLimbToggle;";
        };
        class Chest: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_CHEST;
            text = "Chest";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.42 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""chest""] call afcm_sim_ui_fnc_limbSelect_onLimbToggle;";
        };
        class ArmRight: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_ARM_R;
            text = "Right Arm";
            x = "0.58 * safeZoneW + safeZoneX";
            y = "0.42 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightArm""] call afcm_sim_ui_fnc_limbSelect_onLimbToggle;";
        };
        class LegLeft: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_LEG_L;
            text = "Left Leg";
            x = "0.38 * safeZoneW + safeZoneX";
            y = "0.475 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftLeg""] call afcm_sim_ui_fnc_limbSelect_onLimbToggle;";
        };
        class LegRight: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_LEG_R;
            text = "Right Leg";
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.475 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightLeg""] call afcm_sim_ui_fnc_limbSelect_onLimbToggle;";
        };
        // Text/enabled state set dynamically (fnc_limbSelect_refreshButtons.sqf) - shows how many
        // limbs are currently toggled, disabled with an explanation until at least one is.
        class ApplyTrauma: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_LS_APPLYTRAUMA;
            text = "Select Limb(s) to Continue";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.53 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "call afcm_sim_ui_fnc_limbSelect_onApplyTrauma;";
        };
        // Opens the Preset Library (RscDisplayAFCM_SIM_PresetLibrary) - apply a built-in or
        // user-saved multi-injury preset to this patient in one action, or manage/export/import
        // the user library (DESIGN.md § Injury Presets).
        class Presets: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_PRESETS;
            text = "Presets";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.585 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.04 * safeZoneH";
            action = "call afcm_sim_ui_fnc_limbSelect_onOpenPresets;";
        };
        // Full-unit reset (fullHeal + re-lock unconscious) - the real destructive action, so it
        // gets the danger style here rather than the injury editor's now-local, non-destructive
        // "Reset Limb". Doesn't close the dialog - an instructor may want to immediately pick a
        // limb and start treating again right after wiping the patient.
        class Reset: AFCM_SIM_RscButtonDanger
        {
            idc = IDC_AFCM_SIM_LS_RESET;
            text = "Reset Patient";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.635 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.04 * safeZoneH";
            action = "call afcm_sim_ui_fnc_limbSelect_onResetPatient;";
        };
        class Close: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_CLOSE;
            text = "Close";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.69 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.038 * safeZoneH";
            colorBackground[] = {0.1, 0.1, 0.11, 0.75};
            action = "closeDialog 0;";
        };
    };
};

#define IDD_AFCM_SIM_INJURYEDITOR 25602

#define IDC_AFCM_SIM_IE_TITLE      1
#define IDC_AFCM_SIM_IE_LIMBLABEL  10
#define IDC_AFCM_SIM_IE_WOUNDTYPE  11
#define IDC_AFCM_SIM_IE_SEVERITY   12
#define IDC_AFCM_SIM_IE_BLEEDING   13
#define IDC_AFCM_SIM_IE_APPLY      14
#define IDC_AFCM_SIM_IE_BACK       15
#define IDC_AFCM_SIM_IE_STATUS     16
#define IDC_AFCM_SIM_IE_RESET      17
#define IDC_AFCM_SIM_IE_FRACTURE       18
#define IDC_AFCM_SIM_IE_PNEUMOTHORAX   19
#define IDC_AFCM_SIM_IE_FRACTURELABEL  20
#define IDC_AFCM_SIM_IE_PNEUMOLABEL    21
#define IDC_AFCM_SIM_IE_SAVEPRESET     22

// Second real screen for "Selectable Injuries" (DESIGN.md §5) — wound type, severity, bleed
// toggle, applied identically to every limb selected on the previous screen, plus a live
// medical-status readout (afcm_sim_fnc_backend_getState) refreshed on a per-frame handler while
// the dialog is open. Opened by fnc_limbSelect_onApplyTrauma.sqf right after one or more limbs are
// toggled; Apply remoteExecs to afcm_sim_scenario_fnc_serverApplyInjury (DESIGN.md §6 — never
// applies locally) once per selected limb. Reset ("Reset Limb") is purely local now - just clears the form
// back to defaults, see fnc_injuryEditor_onReset.sqf. The real full-unit reset moved to the
// limb-select ("main") screen's own Reset Patient button (RscDisplayAFCM_SIM_LimbSelect above) -
// it read as misleadingly scoped to one limb sitting here.
//
// Wound type/severity/bleeding work identically for ACE and KAT (ACE_COMPAT.md §3/KAT_COMPAT.md
// §3), so those three stay unconditional. Fracture/Pneumothorax below them are real KAT-specific
// state with no ACE equivalent at all (INJURY_CODES.md §6) — shown/hidden at runtime by
// fnc_injuryEditor_init.sqf (`ctrlShow`) based on `afcm_sim_fnc_backend_getActive`: Fracture only
// when KAT is active, Pneumothorax only when KAT is active AND the selected limb is "chest" (a
// torso-wide condition, not per-limb). Hidden rows just leave blank space in the panel rather than
// reflowing it — Arma dialogs are absolute-positioned, not flow-layout — a deliberate simplicity
// trade-off. fnc_injuryEditor_init.sqf still queries afcm_sim_fnc_backend_getActive to disable
// Apply entirely with an explanation if no usable backend is active at all.
//
// Same branded panel/accent-bar/button kit as the limb-select dialog above, true-centered the same
// way, plus a dedicated "readout box" (StatusBg) behind the live status text so it reads as a
// distinct console-style element rather than plain text floating between the form and the buttons.
// Buttons are role-colored: Apply = primary (accent-tinted), Back/Reset Limb = neutral (neither
// touches real patient state - Back discards the form and returns to limb-select, Reset Limb
// clears it in place).
//
// IDCs here are hardcoded 1/10-21 to match what fnc_injuryEditor_init.sqf/fnc_injuryEditor_onApply.sqf/
// fnc_injuryEditor_onReset.sqf/fnc_injuryEditor_refreshState.sqf read via `_display displayCtrl <n>`
// — keep both in sync if either changes. Decorative controls (Panel/AccentBar/StatusBg) are
// idc=-1 and never read by script.
class RscDisplayAFCM_SIM_InjuryEditor
{
    idd = IDD_AFCM_SIM_INJURYEDITOR;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_injuryEditor_init;";
    onUnload = "call afcm_sim_ui_fnc_injuryEditor_cleanup;";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.29 * safeZoneW + safeZoneX";
            y = "0.215 * safeZoneH + safeZoneY";
            w = "0.42 * safeZoneW";
            h = "0.57 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_IE_TITLE;
            text = "AFCM-Simulator — Injury Editor";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.235 * safeZoneH + safeZoneY";
            w = "0.38 * safeZoneW";
            h = "0.035 * safeZoneH";
            sizeEx = "0.027 * safeZoneH";
        };
        // Text and color set dynamically in fnc_injuryEditor_init.sqf — shows the limb name in a
        // subtle accent tone, or an amber "no backend active" warning if neither ACE nor KAT is
        // actually loaded.
        class LimbLabel: AFCM_SIM_RscSubtitle
        {
            idc = IDC_AFCM_SIM_IE_LIMBLABEL;
            text = "Injury";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.269 * safeZoneH + safeZoneY";
            w = "0.38 * safeZoneW";
            h = "0.028 * safeZoneH";
            sizeEx = "0.019 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.302 * safeZoneH + safeZoneY";
            w = "0.38 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class WoundTypeLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Wound Type";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.32 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class WoundType: RscCombo
        {
            idc = IDC_AFCM_SIM_IE_WOUNDTYPE;
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.32 * safeZoneH + safeZoneY";
            w = "0.19 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class SeverityLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Severity";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.365 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class Severity: RscCombo
        {
            idc = IDC_AFCM_SIM_IE_SEVERITY;
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.365 * safeZoneH + safeZoneY";
            w = "0.19 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class BleedingLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Bleeding";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.41 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Bleeding: RscCheckBox
        {
            idc = IDC_AFCM_SIM_IE_BLEEDING;
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.41 * safeZoneH + safeZoneY";
            w = "0.04 * safeZoneH";
            h = "0.04 * safeZoneH";
        };
        // KAT-only, hidden entirely (ctrlShow false) unless the active backend is "kat" AND at
        // least one selected limb is an arm or a leg - fnc_injuryEditor_init.sqf. Fracture
        // severity is per-limb, real KAT state (kat_surgery_fractures) with no ACE equivalent -
        // see fnc_applyFracture.sqf. Deliberately arms/legs only, not head/chest, even though
        // KAT's own data model has a slot for both.
        class FractureLabel: AFCM_SIM_RscLabel
        {
            idc = IDC_AFCM_SIM_IE_FRACTURELABEL;
            text = "Fracture (Arms/Legs)";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.455 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class Fracture: RscCombo
        {
            idc = IDC_AFCM_SIM_IE_FRACTURE;
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.455 * safeZoneH + safeZoneY";
            w = "0.19 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        // KAT-only, hidden unless the active backend is "kat" AND the selected limb is "chest" -
        // pneumothorax is a torso-wide condition (kat_breathing_pneumothorax/_hemopneumothorax/
        // _tensionpneumothorax), not per-limb, so it doesn't make sense to offer it while editing
        // an arm or a leg. See fnc_applyPneumothorax.sqf.
        class PneumoLabel: AFCM_SIM_RscLabel
        {
            idc = IDC_AFCM_SIM_IE_PNEUMOLABEL;
            text = "Pneumothorax (KAT)";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.5 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class Pneumothorax: RscCombo
        {
            idc = IDC_AFCM_SIM_IE_PNEUMOTHORAX;
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.5 * safeZoneH + safeZoneY";
            w = "0.19 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        // Nested "readout" backdrop behind StatusText, so the live medical-state text reads as a
        // distinct console-style element rather than plain text floating in the form.
        class StatusBg: AFCM_SIM_Panel
        {
            x = "0.305 * safeZoneW + safeZoneX";
            y = "0.548 * safeZoneH + safeZoneY";
            w = "0.395 * safeZoneW";
            h = "0.095 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_STATUS_BG;
        };
        // Live medical state (afcm_sim_fnc_backend_getState), refreshed on a per-frame handler
        // added in fnc_injuryEditor_init.sqf and removed in fnc_injuryEditor_cleanup.sqf while this
        // dialog is open — genuinely live, not just a snapshot from when the dialog opened. Tall
        // enough for a 4th line (fracture/pneumothorax) when KAT is active.
        class StatusText: RscText
        {
            idc = IDC_AFCM_SIM_IE_STATUS;
            text = "";
            x = "0.315 * safeZoneW + safeZoneX";
            y = "0.553 * safeZoneH + safeZoneY";
            w = "0.375 * safeZoneW";
            h = "0.085 * safeZoneH";
            sizeEx = "0.019 * safeZoneH";
            colorText[] = AFCM_SIM_COLOR_TEXT_DIM;
        };
        class Apply: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_IE_APPLY;
            text = "Apply";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.655 * safeZoneH + safeZoneY";
            w = "0.185 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Was "Cancel" (plain closeDialog) - changed to "Back" since closing this dialog outright
        // dropped the instructor out of the whole flow with no way back to picking a different
        // limb without re-triggering the "Edit Injuries" scroll action from scratch.
        // fnc_injuryEditor_onBack.sqf closes this dialog and reopens the limb-select ("main")
        // screen for the same target unit instead.
        class Back: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IE_BACK;
            text = "Back";
            x = "0.505 * safeZoneW + safeZoneX";
            y = "0.655 * safeZoneH + safeZoneY";
            w = "0.185 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Separate row, distinct from Apply/Back - saves the currently-configured wound (and
        // Fracture/Pneumothorax, if visible) as a new single-injury user preset
        // (fnc_injuryEditor_onSavePreset.sqf opens RscDisplayAFCM_SIM_PresetSave to name it) rather
        // than applying it, so an instructor can build a reusable library entry without touching
        // this patient at all. Paired with Reset Limb below it, sharing the row - both are
        // form-only actions, neither touches real patient state.
        class SavePreset: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IE_SAVEPRESET;
            text = "Save as Preset";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.707 * safeZoneH + safeZoneY";
            w = "0.185 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Purely local, clears the form back to defaults (fnc_injuryEditor_onReset.sqf) rather
        // than touching the patient's actual medical state. Neutral style, not danger red - it's
        // no longer destructive.
        class Reset: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IE_RESET;
            text = "Reset Limb";
            x = "0.505 * safeZoneW + safeZoneX";
            y = "0.707 * safeZoneH + safeZoneY";
            w = "0.185 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
    };
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
            y = "0.155 * safeZoneH + safeZoneY";
            w = "0.6 * safeZoneW";
            h = "0.69 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_MC_TITLE;
            text = "MCI Creator";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.175 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.032 * safeZoneH";
        };
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = -1;
            text = "Build a mass-casualty incident, then spawn it wherever you click on the map";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.22 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.017 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.25 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class PatientCountLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Patients";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.265 * safeZoneH + safeZoneY";
            w = "0.15 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class PatientCount: RscCombo
        {
            idc = IDC_AFCM_SIM_MC_PATIENTCOUNT;
            x = "0.37 * safeZoneW + safeZoneX";
            y = "0.265 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class CasualtyTypeLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Casualty Type";
            x = "0.52 * safeZoneW + safeZoneX";
            y = "0.265 * safeZoneH + safeZoneY";
            w = "0.13 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class CasualtyType: RscCombo
        {
            idc = IDC_AFCM_SIM_MC_CASUALTYTYPE;
            x = "0.65 * safeZoneW + safeZoneX";
            y = "0.265 * safeZoneH + safeZoneY";
            w = "0.13 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class PatientListLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Patients (select one)";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.315 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.025 * safeZoneH";
        };
        class PresetListLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Available Presets";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.315 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.025 * safeZoneH";
        };
        class PatientList: RscListBox
        {
            idc = IDC_AFCM_SIM_MC_PATIENTLIST;
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.34 * safeZoneH + safeZoneY";
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
            y = "0.34 * safeZoneH + safeZoneY";
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
            y = "0.57 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class RandomizeAll: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_RANDOMIZEALL;
            text = "Randomize All Patients";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.61 * safeZoneH + safeZoneY";
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
            y = "0.655 * safeZoneH + safeZoneY";
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
            y = "0.69 * safeZoneH + safeZoneY";
            w = "0.56 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class SavePreset: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_SAVEPRESET;
            text = "Save as MCI Preset";
            x = "0.22 * safeZoneW + safeZoneX";
            y = "0.73 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class LoadPreset: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_LOADPRESET;
            text = "Load MCI Preset";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.73 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
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
            y = "0.775 * safeZoneH + safeZoneY";
            w = "0.27 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class Close: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_MC_CLOSE;
            text = "Close";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.775 * safeZoneH + safeZoneY";
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
