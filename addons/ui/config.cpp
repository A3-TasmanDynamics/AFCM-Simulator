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

#define IDD_AFCM_SIM_LIMBSELECT 25601

#define IDC_AFCM_SIM_LS_TITLE       1
#define IDC_AFCM_SIM_LS_HEAD        10
#define IDC_AFCM_SIM_LS_NECK        11
#define IDC_AFCM_SIM_LS_UPARM_L     12
#define IDC_AFCM_SIM_LS_CHEST       13
#define IDC_AFCM_SIM_LS_UPARM_R     14
#define IDC_AFCM_SIM_LS_FOREARM_L   15
#define IDC_AFCM_SIM_LS_ABDOMEN     16
#define IDC_AFCM_SIM_LS_FOREARM_R   17
#define IDC_AFCM_SIM_LS_PELVIS      18
#define IDC_AFCM_SIM_LS_THIGH_L     19
#define IDC_AFCM_SIM_LS_THIGH_R     20
#define IDC_AFCM_SIM_LS_SHIN_L      21
#define IDC_AFCM_SIM_LS_SHIN_R      22
#define IDC_AFCM_SIM_LS_CLOSE       23

class RscText;
class RscButton;

// First real screen for "Selectable Body Limbs" (DESIGN.md §5). This is a plain button-per-limb
// layout, not a clickable body silhouette — a hit-tested silhouette needs a custom texture asset
// (hit-region image) that doesn't exist yet. Functionally equivalent for v1; swapping in a real
// silhouette graphic later only touches this dialog's controls, not the event-bus contract.
//
// 13 buttons, one per real anatomical LimbId (DESIGN.md §4.1 / INJURY_CODES.md §1), arranged
// top-to-bottom/left-to-right roughly matching real body layout: head/neck centered at top, then
// upper-arm/chest/upper-arm, forearm/abdomen/forearm, pelvis centered, then thigh/thigh and
// shin/shin at the bottom.
class RscDisplayAFCM_SIM_LimbSelect
{
    idd = IDD_AFCM_SIM_LIMBSELECT;
    movingEnable = 1;
    onLoad = "";

    class controls
    {
        class Title: RscText
        {
            idc = IDC_AFCM_SIM_LS_TITLE;
            text = "Select Injured Region";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.09 * safeZoneH + safeZoneY";
            w = "0.36 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.03 * safeZoneH";
            colorText[] = {1, 1, 1, 1};
        };
        class Head: RscButton
        {
            idc = IDC_AFCM_SIM_LS_HEAD;
            text = "Head";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.14 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""head""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Neck: RscButton
        {
            idc = IDC_AFCM_SIM_LS_NECK;
            text = "Neck";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.19 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.04 * safeZoneH";
            action = "[""neck""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LeftUpperArm: RscButton
        {
            idc = IDC_AFCM_SIM_LS_UPARM_L;
            text = "Left Upper Arm";
            x = "0.28 * safeZoneW + safeZoneX";
            y = "0.235 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftUpperArm""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Chest: RscButton
        {
            idc = IDC_AFCM_SIM_LS_CHEST;
            text = "Chest";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.235 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""chest""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class RightUpperArm: RscButton
        {
            idc = IDC_AFCM_SIM_LS_UPARM_R;
            text = "Right Upper Arm";
            x = "0.58 * safeZoneW + safeZoneX";
            y = "0.235 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightUpperArm""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LeftForearm: RscButton
        {
            idc = IDC_AFCM_SIM_LS_FOREARM_L;
            text = "Left Forearm";
            x = "0.28 * safeZoneW + safeZoneX";
            y = "0.29 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftForearm""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Abdomen: RscButton
        {
            idc = IDC_AFCM_SIM_LS_ABDOMEN;
            text = "Abdomen";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.29 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""abdomen""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class RightForearm: RscButton
        {
            idc = IDC_AFCM_SIM_LS_FOREARM_R;
            text = "Right Forearm";
            x = "0.58 * safeZoneW + safeZoneX";
            y = "0.29 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightForearm""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Pelvis: RscButton
        {
            idc = IDC_AFCM_SIM_LS_PELVIS;
            text = "Pelvis";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.345 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""pelvis""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LeftThigh: RscButton
        {
            idc = IDC_AFCM_SIM_LS_THIGH_L;
            text = "Left Thigh";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.40 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftThigh""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class RightThigh: RscButton
        {
            idc = IDC_AFCM_SIM_LS_THIGH_R;
            text = "Right Thigh";
            x = "0.54 * safeZoneW + safeZoneX";
            y = "0.40 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightThigh""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LeftShin: RscButton
        {
            idc = IDC_AFCM_SIM_LS_SHIN_L;
            text = "Left Shin";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.455 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""leftShin""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class RightShin: RscButton
        {
            idc = IDC_AFCM_SIM_LS_SHIN_R;
            text = "Right Shin";
            x = "0.54 * safeZoneW + safeZoneX";
            y = "0.455 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""rightShin""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Close: RscButton
        {
            idc = IDC_AFCM_SIM_LS_CLOSE;
            text = "Close";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.515 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
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

class RscCombo;
class RscCheckBox;

// Second real screen for "Selectable Injuries" (DESIGN.md §5) — wound type, severity, bleed
// toggle, per limb, plus a live medical-status readout (afcm_sim_fnc_backend_getState) refreshed
// on a per-frame handler while the dialog is open. Opened by fnc_limbSelect_onLimbClick.sqf right
// after a limb is picked; Apply remoteExecs to afcm_sim_scenario_fnc_serverApplyInjury (DESIGN.md
// §6 — never applies locally). Reset remoteExecs to afcm_sim_scenario_fnc_serverReset (fullHeal +
// re-lock unconscious) and keeps the dialog open, unlike Apply/Cancel.
// IDCs here are hardcoded 1/10-17 to match what fnc_injuryEditor_init.sqf/fnc_injuryEditor_onApply.sqf/
// fnc_injuryEditor_onReset.sqf/fnc_injuryEditor_refreshState.sqf read via `_display displayCtrl <n>`
// — keep both in sync if either changes.
class RscDisplayAFCM_SIM_InjuryEditor
{
    idd = IDD_AFCM_SIM_INJURYEDITOR;
    movingEnable = 1;
    onLoad = "call afcm_sim_ui_fnc_injuryEditor_init;";
    onUnload = "call afcm_sim_ui_fnc_injuryEditor_cleanup;";

    class controls
    {
        class Title: RscText
        {
            idc = IDC_AFCM_SIM_IE_TITLE;
            text = "AFCM-Simulator — Injury Editor";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.28 * safeZoneH + safeZoneY";
            w = "0.36 * safeZoneW";
            h = "0.035 * safeZoneH";
            sizeEx = "0.025 * safeZoneH";
            colorText[] = {1, 1, 1, 1};
        };
        class LimbLabel: RscText
        {
            idc = IDC_AFCM_SIM_IE_LIMBLABEL;
            text = "Injury";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.315 * safeZoneH + safeZoneY";
            w = "0.36 * safeZoneW";
            h = "0.035 * safeZoneH";
            sizeEx = "0.022 * safeZoneH";
            colorText[] = {0.76, 0.68, 0.62, 1};
        };
        class WoundTypeLabel: RscText
        {
            idc = -1;
            text = "Wound Type";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.365 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorText[] = {1, 1, 1, 1};
        };
        class WoundType: RscCombo
        {
            idc = IDC_AFCM_SIM_IE_WOUNDTYPE;
            x = "0.5 * safeZoneW + safeZoneX";
            y = "0.365 * safeZoneH + safeZoneY";
            w = "0.18 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class SeverityLabel: RscText
        {
            idc = -1;
            text = "Severity";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.415 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorText[] = {1, 1, 1, 1};
        };
        class Severity: RscCombo
        {
            idc = IDC_AFCM_SIM_IE_SEVERITY;
            x = "0.5 * safeZoneW + safeZoneX";
            y = "0.415 * safeZoneH + safeZoneY";
            w = "0.18 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class BleedingLabel: RscText
        {
            idc = -1;
            text = "Bleeding";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.465 * safeZoneH + safeZoneY";
            w = "0.16 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorText[] = {1, 1, 1, 1};
        };
        class Bleeding: RscCheckBox
        {
            idc = IDC_AFCM_SIM_IE_BLEEDING;
            x = "0.5 * safeZoneW + safeZoneX";
            y = "0.465 * safeZoneH + safeZoneY";
            w = "0.04 * safeZoneH";
            h = "0.04 * safeZoneH";
        };
        // Live medical state (afcm_sim_fnc_backend_getState), refreshed on a per-frame handler
        // added in fnc_injuryEditor_init.sqf and removed in fnc_injuryEditor_cleanup.sqf while this
        // dialog is open — genuinely live, not just a snapshot from when the dialog opened.
        class StatusText: RscText
        {
            idc = IDC_AFCM_SIM_IE_STATUS;
            text = "";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.515 * safeZoneH + safeZoneY";
            w = "0.36 * safeZoneW";
            h = "0.065 * safeZoneH";
            sizeEx = "0.02 * safeZoneH";
            colorText[] = {0.85, 0.85, 0.8, 1};
        };
        class Apply: RscButton
        {
            idc = IDC_AFCM_SIM_IE_APPLY;
            text = "Apply";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.59 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        class Cancel: RscButton
        {
            idc = IDC_AFCM_SIM_IE_CANCEL;
            text = "Cancel";
            x = "0.51 * safeZoneW + safeZoneX";
            y = "0.59 * safeZoneH + safeZoneY";
            w = "0.17 * safeZoneW";
            h = "0.045 * safeZoneH";
        };
        // Separate row, distinct from Apply/Cancel - wipes everything done to the patient so far
        // and starts the exercise over, rather than committing/discarding one injury.
        class Reset: RscButton
        {
            idc = IDC_AFCM_SIM_IE_RESET;
            text = "Reset Patient";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.645 * safeZoneH + safeZoneY";
            w = "0.36 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0.5, 0.15, 0.13, 1};
        };
    };
};
