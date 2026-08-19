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
class CfgFunctions
{
    class afcm_sim_ui
    {
        tag = "afcm_sim_ui";
        class EventBus
        {
            file = "ui\functions";
            class publish {};
            class subscribe {};
        };
        class LimbSelect
        {
            file = "ui\functions";
            class limbSelect_open {};
            class limbSelect_onLimbClick {};
        };
    };
};

#define IDD_AFCM_SIM_LIMBSELECT 25601

#define IDC_AFCM_SIM_LS_TITLE   1
#define IDC_AFCM_SIM_LS_HEAD    10
#define IDC_AFCM_SIM_LS_TORSO   11
#define IDC_AFCM_SIM_LS_ARM_L   12
#define IDC_AFCM_SIM_LS_ARM_R   13
#define IDC_AFCM_SIM_LS_LEG_L   14
#define IDC_AFCM_SIM_LS_LEG_R   15
#define IDC_AFCM_SIM_LS_CLOSE   16

class RscText;
class RscButton;

// First real screen for "Selectable Body Limbs" (DESIGN.md §5). This is a plain button-per-limb
// layout, not a clickable body silhouette — a hit-tested silhouette needs a custom texture asset
// (hit-region image) that doesn't exist yet. Functionally equivalent for v1; swapping in a real
// silhouette graphic later only touches this dialog's controls, not the event-bus contract.
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
            text = "Select Injured Limb";
            x = "0.35 * safeZoneW + safeZoneX";
            y = "0.20 * safeZoneH + safeZoneY";
            w = "0.30 * safeZoneW";
            h = "0.04 * safeZoneH";
            sizeEx = "0.03 * safeZoneH";
            colorText[] = {1, 1, 1, 1};
        };
        class Head: RscButton
        {
            idc = IDC_AFCM_SIM_LS_HEAD;
            text = "Head";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.25 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.05 * safeZoneH";
            action = "[""head""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Torso: RscButton
        {
            idc = IDC_AFCM_SIM_LS_TORSO;
            text = "Torso";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.31 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.05 * safeZoneH";
            action = "[""torso""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ArmLeft: RscButton
        {
            idc = IDC_AFCM_SIM_LS_ARM_L;
            text = "Left Arm";
            x = "0.30 * safeZoneW + safeZoneX";
            y = "0.31 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.05 * safeZoneH";
            action = "[""armLeft""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class ArmRight: RscButton
        {
            idc = IDC_AFCM_SIM_LS_ARM_R;
            text = "Right Arm";
            x = "0.58 * safeZoneW + safeZoneX";
            y = "0.31 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.05 * safeZoneH";
            action = "[""armRight""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LegLeft: RscButton
        {
            idc = IDC_AFCM_SIM_LS_LEG_L;
            text = "Left Leg";
            x = "0.38 * safeZoneW + safeZoneX";
            y = "0.38 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.05 * safeZoneH";
            action = "[""legLeft""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class LegRight: RscButton
        {
            idc = IDC_AFCM_SIM_LS_LEG_R;
            text = "Right Leg";
            x = "0.50 * safeZoneW + safeZoneX";
            y = "0.38 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.05 * safeZoneH";
            action = "[""legRight""] call afcm_sim_ui_fnc_limbSelect_onLimbClick;";
        };
        class Close: RscButton
        {
            idc = IDC_AFCM_SIM_LS_CLOSE;
            text = "Close";
            x = "0.44 * safeZoneW + safeZoneX";
            y = "0.46 * safeZoneH + safeZoneY";
            w = "0.12 * safeZoneW";
            h = "0.05 * safeZoneH";
            action = "closeDialog 0;";
        };
    };
};
