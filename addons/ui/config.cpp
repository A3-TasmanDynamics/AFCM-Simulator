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
            class addInjuryEditorAction { file = "\afcm_sim\addons\ui\functions\fnc_addInjuryEditorAction.sqf"; };
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

// First real screen for "Selectable Body Limbs" (DESIGN.md §5). Still a plain button-per-limb
// layout, not a clickable body silhouette — a hit-tested silhouette needs a custom texture asset
// (hit-region image) that doesn't exist yet. Now sits on a branded panel backdrop (AFCM_SIM_Panel
// + AFCM_SIM_AccentBar) instead of floating bare buttons directly over the game world.
//
// 6 buttons, a direct 1:1 match to ACE3's own real body parts (DESIGN.md §4.1 / INJURY_CODES.md
// §1) — deliberately kept this simple rather than a finer anatomical breakdown that was built and
// then reverted. Arranged in a rough body layout: head at top, arms either side of chest, legs
// at the bottom. Decorative controls (Panel/Subtitle/AccentBar) are idc=-1 and never read by
// script; only the button/title IDCs above need to stay in sync with fnc_limbSelect_*.sqf.
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
            y = "0.065 * safeZoneH + safeZoneY";
            w = "0.44 * safeZoneW";
            h = "0.34 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_LS_TITLE;
            text = "Select Injured Region";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.085 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.032 * safeZoneH";
        };
        class Subtitle: AFCM_SIM_RscSubtitle
        {
            idc = -1;
            text = "Click a body region to begin treatment";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.123 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.025 * safeZoneH";
            sizeEx = "0.017 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.153 * safeZoneH + safeZoneY";
            w = "0.40 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class Head: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_HEAD;
            text = "Head";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.175 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""head""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ArmLeft: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_ARM_L;
            text = "Left Arm";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.23 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftArm""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Chest: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_CHEST;
            text = "Chest";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.23 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""chest""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ArmRight: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_ARM_R;
            text = "Right Arm";
            x = "0.58 * safeZoneW + safeZoneX";
            y = "0.23 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightArm""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LegLeft: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_LEG_L;
            text = "Left Leg";
            x = "0.38 * safeZoneW + safeZoneX";
            y = "0.285 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftLeg""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LegRight: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_LEG_R;
            text = "Right Leg";
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.285 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightLeg""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Close: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_LS_CLOSE;
            text = "Close";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.34 * safeZoneH + safeZoneY";
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

// Second real screen for "Selectable Injuries" (DESIGN.md §5) — wound type, severity, bleed
// toggle, per limb, plus a live medical-status readout (afcm_sim_fnc_backend_getState) refreshed
// on a per-frame handler while the dialog is open. Opened by fnc_limbSelect_onLimbClick.sqf right
// after a limb is picked; Apply remoteExecs to afcm_sim_scenario_fnc_serverApplyInjury (DESIGN.md
// §6 — never applies locally). Reset remoteExecs to afcm_sim_scenario_fnc_serverReset (fullHeal +
// re-lock unconscious) and keeps the dialog open, unlike Apply/Cancel.
//
// Deliberately ACE-only selections: wound type/severity/bleeding, nothing backend-specific beyond
// that. fnc_injuryEditor_init.sqf still queries afcm_sim_fnc_backend_getActive to disable Apply
// with an explanation if no usable backend is active, but doesn't otherwise branch on which one —
// ACE and KAT both consume these same real calls identically (ACE_COMPAT.md §3/KAT_COMPAT.md §3).
// A KAT-specific Fracture/Pneumothorax extension was built and then reverted here in favour of
// keeping this simple; the real KAT-only functions it would have used
// (kat_surgery_fractures/kat_breathing_*) are still documented in INJURY_CODES.md §6 if revisited.
//
// Same branded panel/accent-bar/button kit as the limb-select dialog above, plus a dedicated
// "readout box" (StatusBg) behind the live status text so it reads as a distinct console-style
// element rather than plain text floating between the form and the buttons. Buttons are
// role-colored: Apply = primary (accent-tinted), Cancel = neutral, Reset Patient = danger (red).
//
// IDCs here are hardcoded 1/10-17 to match what fnc_injuryEditor_init.sqf/fnc_injuryEditor_onApply.sqf/
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
            y = "0.165 * safeZoneH + safeZoneY";
            w = "0.42 * safeZoneW";
            h = "0.465 * safeZoneH";
        };
        class Title: AFCM_SIM_RscTitle
        {
            idc = IDC_AFCM_SIM_IE_TITLE;
            text = "AFCM-Simulator — Injury Editor";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.185 * safeZoneH + safeZoneY";
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
            y = "0.219 * safeZoneH + safeZoneY";
            w = "0.38 * safeZoneW";
            h = "0.028 * safeZoneH";
            sizeEx = "0.019 * safeZoneH";
        };
        class AccentBar: AFCM_SIM_AccentBar
        {
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.252 * safeZoneH + safeZoneY";
            w = "0.38 * safeZoneW";
            h = "0.0025 * safeZoneH";
        };
        class WoundTypeLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Wound Type";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.27 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class WoundType: RscCombo
        {
            idc = IDC_AFCM_SIM_IE_WOUNDTYPE;
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.27 * safeZoneH + safeZoneY";
            w = "0.19 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class SeverityLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Severity";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.315 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class Severity: RscCombo
        {
            idc = IDC_AFCM_SIM_IE_SEVERITY;
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.315 * safeZoneH + safeZoneY";
            w = "0.19 * safeZoneW";
            h = "0.038 * safeZoneH";
        };
        class BleedingLabel: AFCM_SIM_RscLabel
        {
            idc = -1;
            text = "Bleeding";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.36 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Bleeding: RscCheckBox
        {
            idc = IDC_AFCM_SIM_IE_BLEEDING;
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.36 * safeZoneH + safeZoneY";
            w = "0.04 * safeZoneH";
            h = "0.04 * safeZoneH";
        };
        // Nested "readout" backdrop behind StatusText, so the live medical-state text reads as a
        // distinct console-style element rather than plain text floating in the form.
        class StatusBg: AFCM_SIM_Panel
        {
            x = "0.305 * safeZoneW + safeZoneX";
            y = "0.408 * safeZoneH + safeZoneY";
            w = "0.395 * safeZoneW";
            h = "0.08 * safeZoneH";
            colorBackground[] = AFCM_SIM_COLOR_STATUS_BG;
        };
        // Live medical state (afcm_sim_fnc_backend_getState), refreshed on a per-frame handler
        // added in fnc_injuryEditor_init.sqf and removed in fnc_injuryEditor_cleanup.sqf while this
        // dialog is open — genuinely live, not just a snapshot from when the dialog opened.
        class StatusText: RscText
        {
            idc = IDC_AFCM_SIM_IE_STATUS;
            text = "";
            x = "0.315 * safeZoneW + safeZoneX";
            y = "0.413 * safeZoneH + safeZoneY";
            w = "0.375 * safeZoneW";
            h = "0.07 * safeZoneH";
            sizeEx = "0.019 * safeZoneH";
            colorText[] = AFCM_SIM_COLOR_TEXT_DIM;
        };
        class Apply: AFCM_SIM_RscButtonPrimary
        {
            idc = IDC_AFCM_SIM_IE_APPLY;
            text = "Apply";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.5 * safeZoneH + safeZoneY";
            w = "0.185 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class Cancel: AFCM_SIM_RscButton
        {
            idc = IDC_AFCM_SIM_IE_CANCEL;
            text = "Cancel";
            x = "0.505 * safeZoneW + safeZoneX";
            y = "0.5 * safeZoneH + safeZoneY";
            w = "0.185 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Separate row, distinct from Apply/Cancel - wipes everything done to the patient so far
        // and starts the exercise over, rather than committing/discarding one injury.
        class Reset: AFCM_SIM_RscButtonDanger
        {
            idc = IDC_AFCM_SIM_IE_RESET;
            text = "Reset Patient";
            x = "0.31 * safeZoneW + safeZoneX";
            y = "0.552 * safeZoneH + safeZoneY";
            w = "0.38 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
    };
};
