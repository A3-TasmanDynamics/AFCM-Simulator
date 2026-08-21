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
        class UpperArmLeft: RscButton
        {
            idc = IDC_AFCM_SIM_LS_UPARM_L;
            text = "Left Upper Arm";
            x = "0.28 * safeZoneW + safeZoneX";
            y = "0.235 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""upperArmLeft""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
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
        class UpperArmRight: RscButton
        {
            idc = IDC_AFCM_SIM_LS_UPARM_R;
            text = "Right Upper Arm";
            x = "0.58 * safeZoneW + safeZoneX";
            y = "0.235 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""upperArmRight""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ForearmLeft: RscButton
        {
            idc = IDC_AFCM_SIM_LS_FOREARM_L;
            text = "Left Forearm";
            x = "0.28 * safeZoneW + safeZoneX";
            y = "0.29 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""forearmLeft""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
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
        class ForearmRight: RscButton
        {
            idc = IDC_AFCM_SIM_LS_FOREARM_R;
            text = "Right Forearm";
            x = "0.58 * safeZoneW + safeZoneX";
            y = "0.29 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""forearmRight""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
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
        class ThighLeft: RscButton
        {
            idc = IDC_AFCM_SIM_LS_THIGH_L;
            text = "Left Thigh";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.40 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""thighLeft""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ThighRight: RscButton
        {
            idc = IDC_AFCM_SIM_LS_THIGH_R;
            text = "Right Thigh";
            x = "0.54 * safeZoneW + safeZoneX";
            y = "0.40 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""thighRight""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ShinLeft: RscButton
        {
            idc = IDC_AFCM_SIM_LS_SHIN_L;
            text = "Left Shin";
            x = "0.32 * safeZoneW + safeZoneX";
            y = "0.455 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""shinLeft""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ShinRight: RscButton
        {
            idc = IDC_AFCM_SIM_LS_SHIN_R;
            text = "Right Shin";
            x = "0.54 * safeZoneW + safeZoneX";
            y = "0.455 * safeZoneH + safeZoneY";
            w = "0.14 * safeZoneW";
            h = "0.045 * safeZoneH";
            action = "[""shinRight""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
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
