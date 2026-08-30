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
            class limbSelect_onLimbClick { file = "\afcm_sim\addons\ui\functions\fnc_limbSelect_onLimbClick.sqf"; };
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
            class injuryEditor_onReset { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_onReset.sqf"; };
            class injuryEditor_refreshState { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_refreshState.sqf"; };
            class injuryEditor_onSavePreset { file = "\afcm_sim\addons\ui\functions\fnc_injuryEditor_onSavePreset.sqf"; };
            class addInjuryEditorAction { file = "\afcm_sim\addons\ui\functions\fnc_addInjuryEditorAction.sqf"; };
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

// First real screen for "Selectable Body Limbs" (DESIGN.md §5). Still a plain button-per-limb
// layout, not a clickable body silhouette — a hit-tested silhouette needs a custom texture asset
// (hit-region image) that doesn't exist yet. Sits on a branded panel backdrop (AFCM_SIM_Panel +
// AFCM_SIM_AccentBar), true-centered on screen — panel width/height are chosen so
// `x = (1 - w) / 2` and `y = (1 - h) / 2` land the whole thing dead-center of the safe zone
// regardless of resolution/aspect ratio (safeZoneW/H/X/Y are themselves already resolution-aware).
//
// 6 buttons, a direct 1:1 match to ACE3's own real body parts (DESIGN.md §4.1 / INJURY_CODES.md
// §1) — deliberately kept this simple rather than a finer anatomical breakdown that was built and
// then reverted. Arranged in a rough body layout: head at top, arms either side of chest, legs
// at the bottom, then a full-width Presets button (opens RscDisplayAFCM_SIM_PresetLibrary below),
// then a full-width Reset Patient button (the real, full-unit afcm_sim_fnc_backend_reset dispatch
// - moved here from the injury editor, which now has its own much lighter, purely-local
// "Reset Limb", see RscDisplayAFCM_SIM_InjuryEditor below), then Close. Decorative controls
// (Panel/Subtitle/AccentBar) are idc=-1 and never read by script; only the button/title IDCs above
// need to stay in sync with fnc_limbSelect_*.sqf.
class RscDisplayAFCM_SIM_LimbSelect
{
    idd = IDD_AFCM_SIM_LIMBSELECT;
    movingEnable = 1;
    onLoad = "";

    class controls
    {
        class Panel: AFCM_SIM_Panel
        {
            x = "0.28 * safeZoneW + safeZoneX";
            y = "0.275 * safeZoneH + safeZoneY";
            w = "0.44 * safeZoneW";
            h = "0.45 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_LS_TITLE;
            text = "Select Injured Region";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.295 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.032 * safeZoneH";
        };
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = -1;
            text = "Click a body region to begin treatment";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.333 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.017 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.365 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class Head: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_HEAD;
            text = "Head";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.39 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""head""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ArmLeft: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_ARM_L;
            text = "Left Arm";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.445 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftArm""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Chest: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_CHEST;
            text = "Chest";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.445 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""chest""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ArmRight: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_ARM_R;
            text = "Right Arm";
            x = "0.58 * safeZoneW + safeZoneX";
            y = "0.445 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightArm""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LegLeft: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_LEG_L;
            text = "Left Leg";
            x = "0.38 * safeZoneW + safeZoneX";
            y = "0.50 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftLeg""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LegRight: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_LEG_R;
            text = "Right Leg";
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.50 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightLeg""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        // Opens the Preset Library (RscDisplayAFCM_SIM_PresetLibrary) - apply a built-in or
        // user-saved multi-injury preset to this patient in one action, or manage/export/import
        // the user library (DESIGN.md § Injury Presets).
        class Presets: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_PRESETS;
            text = "Presets";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.555 * safeZoneH + safeZoneY";
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
            y = "0.605 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.04 * safeZoneH";
            action = "call afcm_sim_ui_fnc_limbSelect_onResetPatient;";
        };
        class Close: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_CLOSE;
            text = "Close";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.66 * safeZoneH + safeZoneY";
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
#define IDC_AFCM_SIM_IE_CANCEL     15
#define IDC_AFCM_SIM_IE_STATUS     16
#define IDC_AFCM_SIM_IE_RESET      17
#define IDC_AFCM_SIM_IE_FRACTURE       18
#define IDC_AFCM_SIM_IE_PNEUMOTHORAX   19
#define IDC_AFCM_SIM_IE_FRACTURELABEL  20
#define IDC_AFCM_SIM_IE_PNEUMOLABEL    21
#define IDC_AFCM_SIM_IE_SAVEPRESET     22

// Second real screen for "Selectable Injuries" (DESIGN.md §5) — wound type, severity, bleed
// toggle, per limb, plus a live medical-status readout (afcm_sim_fnc_backend_getState) refreshed
// on a per-frame handler while the dialog is open. Opened by fnc_limbSelect_onLimbClick.sqf right
// after a limb is picked; Apply remoteExecs to afcm_sim_scenario_fnc_serverApplyInjury (DESIGN.md
// §6 — never applies locally). Reset ("Reset Limb") is purely local now - just clears the form
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
// Buttons are role-colored: Apply = primary (accent-tinted), Cancel/Reset Limb = neutral (neither
// touches real patient state - Cancel discards the form, Reset Limb clears it).
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
        // KAT-only, hidden entirely (ctrlShow false) unless the active backend is "kat" -
        // fnc_injuryEditor_init.sqf. Fracture severity is per-limb, real KAT state
        // (kat_surgery_fractures) with no ACE equivalent - see fnc_applyFracture.sqf.
        class FractureLabel: AFCM_SIM_RscLabel
        {
            idc = IDC_AFCM_SIM_IE_FRACTURELABEL;
            text = "Fracture (KAT)";
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
        class Cancel: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IE_CANCEL;
            text = "Cancel";
            x = "0.505 * safeZoneW + safeZoneX";
            y = "0.655 * safeZoneH + safeZoneY";
            w = "0.185 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Separate row, distinct from Apply/Cancel - saves the currently-configured wound (and
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
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = -1;
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
