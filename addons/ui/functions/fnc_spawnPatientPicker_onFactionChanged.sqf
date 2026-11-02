/*
 * Author: Tasman Dynamics
 * LBSelChanged handler for RscDisplayAFCM_SIM_SpawnPatientPicker's Faction combo (idc 10) - also
 * called directly by fnc_spawnPatientPicker_init.sqf to populate the Unit Type combo (idc 13) for
 * whatever faction is selected on open. Repopulates Unit Type from
 * afcm_sim_ui_fnc_getSpawnPatientUnitRoster for the newly-selected faction and restores the last
 * real unit picked for THAT faction specifically from profileNamespace
 * (AFCM_SIM_lastSpawnPatientUnitClass, keyed per faction so switching factions and back doesn't
 * lose either one's remembered pick), falling back to index 0 the first time a given faction is
 * ever picked.
 *
 * Arguments:
 * 0: Faction combo <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_ctrlFaction"];

disableSerialization;
private _display = ctrlParent _ctrlFaction;
private _ctrlUnitType = _display displayCtrl 13;

private _casualtyType = lbCurSel _ctrlFaction;
if (_casualtyType == -1) then { _casualtyType = 0; };

private _roster = [_casualtyType] call afcm_sim_ui_fnc_getSpawnPatientUnitRoster;

lbClear _ctrlUnitType;
{
    _x params ["_label", "_classname"];
    _ctrlUnitType lbAdd _label;
    _ctrlUnitType lbSetData [_forEachIndex, _classname];
} forEach _roster;

private _lastClasses = profileNamespace getVariable ["AFCM_SIM_lastSpawnPatientUnitClass", []];
private _lastClass = _lastClasses param [_casualtyType, ""];
private _lastIndex = _roster findIf { (_x select 1) == _lastClass };
if (_lastIndex == -1) then { _lastIndex = 0; };

_ctrlUnitType lbSetCurSel _lastIndex;
