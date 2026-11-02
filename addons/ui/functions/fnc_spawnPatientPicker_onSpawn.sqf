/*
 * Author: Tasman Dynamics
 * ButtonClick handler for RscDisplayAFCM_SIM_SpawnPatientPicker's Spawn Patient button.
 *
 * Persists the chosen Faction to profileNamespace (AFCM_SIM_lastSpawnPatientCasualtyType) and the
 * chosen Unit Type's real classname to AFCM_SIM_lastSpawnPatientUnitClass (keyed per faction - see
 * fnc_spawnPatientPicker_onFactionChanged.sqf) - the real "remember my last choice" mechanism
 * fnc_spawnPatientPicker_init.sqf/onFactionChanged.sqf read back on the NEXT module placement, on
 * request. Then remoteExecs the real spawn (afcm_sim_spawner_fnc_spawnPatient, DESIGN.md §6 - never
 * spawns locally), passing the Unit Type combo's selected classname (lbData, idc 13) as the new
 * trailing `_unitClass` override, plus clientOwner so the server callbacks straight back to
 * afcm_sim_ui_fnc_injuryAuthor_onPatientSpawned once the unit exists, which itself now opens the
 * Injury Author directly on the new unit when this picker's own dialog isn't open (real, confirmed
 * fix - see that function's own docstring) - the "auto-open edit injuries after spawning" flow on
 * request ("Once I have selected the patient faction and unit type, it then opens to the edit
 * injury window... Place spawn patient module > select faction and unit window, select apply > auto
 * opens edit injuries window").
 *
 * Clears AFCM_SIM_UI_spawnPatientPickerLogic to objNull BEFORE deleting it here, so
 * fnc_spawnPatientPicker_cleanup.sqf's own onUnload delete (which handles the Cancel/Escape case)
 * sees it already gone and doesn't try to delete an already-deleted object.
 *
 * Arguments (from the ButtonClick event, not called directly):
 * 0: Spawn Patient button <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlSpawn"];

disableSerialization;
private _display = ctrlParent _ctrlSpawn;

private _casualtyType = lbCurSel (_display displayCtrl 10);
if (_casualtyType == -1) then { _casualtyType = 0; };

private _ctrlUnitType = _display displayCtrl 13;
private _unitTypeSel = lbCurSel _ctrlUnitType;
private _unitClass = if (_unitTypeSel == -1) then { "" } else { _ctrlUnitType lbData _unitTypeSel };

profileNamespace setVariable ["AFCM_SIM_lastSpawnPatientCasualtyType", _casualtyType];
private _lastClasses = profileNamespace getVariable ["AFCM_SIM_lastSpawnPatientUnitClass", []];
while {count _lastClasses < 4} do { _lastClasses pushBack ""; };
_lastClasses set [_casualtyType, _unitClass];
profileNamespace setVariable ["AFCM_SIM_lastSpawnPatientUnitClass", _lastClasses];
saveProfileNamespace;

private _logic = missionNamespace getVariable ["AFCM_SIM_UI_spawnPatientPickerLogic", objNull];
private _pos = missionNamespace getVariable ["AFCM_SIM_UI_spawnPatientPickerPos", []];
private _sessionLabel = missionNamespace getVariable ["AFCM_SIM_UI_spawnPatientPickerSessionLabel", ""];

if (_pos isNotEqualTo []) then {
    [_pos, [], _casualtyType, "", _sessionLabel, [], clientOwner, false, _unitClass] remoteExec ["afcm_sim_spawner_fnc_spawnPatient", 2];
};

missionNamespace setVariable ["AFCM_SIM_UI_spawnPatientPickerLogic", objNull];
if !(isNull _logic) then { deleteVehicle _logic; };

closeDialog 0;
