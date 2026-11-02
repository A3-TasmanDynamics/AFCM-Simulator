/*
 * Author: Tasman Dynamics
 * Returns [[label, classname], ...] for the Spawn Patient Picker's Unit Type combo - on request
 * ("the faction select window must also include a drop down to select the unit type/character.
 * Similar to the reinforcements module, select a faction, that then shows the available units in
 * the faction, select the unit, then apply"), modeled on the vanilla Zeus Reinforcements module's
 * own faction-then-unit two-step UX.
 *
 * Every classname below is real and verified, not guessed - extracted directly from this machine's
 * own installed vanilla characters_f.pbo (derapped via Arma 3 Tools' BankRev + CfgConvert) and
 * confirmed scope=2 (player-usable, not an abstract base class) in its own CfgVehicles. BLUFOR/
 * OPFOR/Independent all expose the identical real role suffix set (soldier_AR_F, medic_F,
 * officer_F, engineer_F, soldier_repair_F, crew_F, helipilot_F, pilot_F, soldier_AT_F, soldier_AA_F,
 * soldier_UAV_F, Soldier_TL_F, Soldier_GL_F, soldier_M_F) under all 3 real B_/O_/I_ prefixes, so the
 * same 15 standard Arma 3 infantry role labels (Rifleman, Medic, Officer, etc.) apply to all three.
 * Civilian has no role concept - just 9 real, distinct vanilla skins (C_man_1 and its real polo/
 * fugitive siblings).
 *
 * Gear is stripped to bare clothing on every spawn path regardless (fnc_spawnPatient.sqf's own
 * existing comment), so whichever entry is picked here only changes the patient's visual model -
 * consistent with every other Casualty Type selection in this addon.
 *
 * Arguments:
 * 0: Casualty type <NUMBER> - 0=Civilian, 1=BLUFOR, 2=OPFOR, 3=Independent (default 0)
 *
 * Return Value:
 * Array of [Label <STRING>, Classname <STRING>]
 *
 * Public: Yes
*/

params [["_casualtyType", 0]];

switch (_casualtyType) do {
    case 1: {
        [
            ["Rifleman", "B_Soldier_F"],
            ["Team Leader", "B_Soldier_TL_F"],
            ["Automatic Rifleman", "B_soldier_AR_F"],
            ["Grenadier", "B_Soldier_GL_F"],
            ["Marksman", "B_soldier_M_F"],
            ["Medic", "B_medic_F"],
            ["Officer", "B_officer_F"],
            ["Engineer", "B_engineer_F"],
            ["Repair Specialist", "B_soldier_repair_F"],
            ["Crewman", "B_crew_F"],
            ["Helicopter Pilot", "B_Helipilot_F"],
            ["Pilot", "B_Pilot_F"],
            ["AT Specialist", "B_soldier_AT_F"],
            ["AA Specialist", "B_soldier_AA_F"],
            ["UAV Operator", "B_soldier_UAV_F"]
        ]
    };
    case 2: {
        [
            ["Rifleman", "O_Soldier_F"],
            ["Team Leader", "O_Soldier_TL_F"],
            ["Automatic Rifleman", "O_Soldier_AR_F"],
            ["Grenadier", "O_Soldier_GL_F"],
            ["Marksman", "O_soldier_M_F"],
            ["Medic", "O_medic_F"],
            ["Officer", "O_officer_F"],
            ["Engineer", "O_engineer_F"],
            ["Repair Specialist", "O_soldier_repair_F"],
            ["Crewman", "O_crew_F"],
            ["Helicopter Pilot", "O_helipilot_F"],
            ["Pilot", "O_Pilot_F"],
            ["AT Specialist", "O_Soldier_AT_F"],
            ["AA Specialist", "O_Soldier_AA_F"],
            ["UAV Operator", "O_soldier_UAV_F"]
        ]
    };
    case 3: {
        [
            ["Rifleman", "I_soldier_F"],
            ["Team Leader", "I_Soldier_TL_F"],
            ["Automatic Rifleman", "I_Soldier_AR_F"],
            ["Grenadier", "I_Soldier_GL_F"],
            ["Marksman", "I_Soldier_M_F"],
            ["Medic", "I_medic_F"],
            ["Officer", "I_officer_F"],
            ["Engineer", "I_engineer_F"],
            ["Repair Specialist", "I_Soldier_repair_F"],
            ["Crewman", "I_crew_F"],
            ["Helicopter Pilot", "I_helipilot_F"],
            ["Pilot", "I_pilot_F"],
            ["AT Specialist", "I_Soldier_AT_F"],
            ["AA Specialist", "I_Soldier_AA_F"],
            ["UAV Operator", "I_soldier_UAV_F"]
        ]
    };
    default {
        [
            ["Civilian 1", "C_man_1"],
            ["Civilian 2", "C_man_1_1_F"],
            ["Civilian 3", "C_man_polo_1_F"],
            ["Civilian 4", "C_man_polo_2_F"],
            ["Civilian 5", "C_man_polo_3_F"],
            ["Civilian 6", "C_man_polo_4_F"],
            ["Civilian 7", "C_man_polo_5_F"],
            ["Civilian 8", "C_man_polo_6_F"],
            ["Fugitive", "C_man_p_fugitive_F"]
        ]
    };
};
