/*
 * Author: Tasman Dynamics
 * Rolls a concrete set of Injury objects (DESIGN.md §4.2) from an injury-level profile
 * (DESIGN.md §4.4 — Easy/Medium/Hard/Extreme/F*CKED!). Backend-agnostic: produces `LimbId`s and
 * generic wound-type identifiers only, never anything backend-specific — whichever backend is
 * active maps these itself (DESIGN.md §4.1).
 *
 * Ranges are the starting proposal from DESIGN.md §4.4, not yet tuned against either backend's
 * real thresholds.
 *
 * Arguments:
 * 0: Injury level <NUMBER> - 0=Easy, 1=Medium, 2=Hard, 3=Extreme, 4=F*CKED! (clamped to range)
 *
 * Return Value:
 * Array of Injury <HASHMAP> - see DESIGN.md §4.2
 *
 * Example:
 * [1] call afcm_sim_scenario_fnc_randomizeInjuries
 *
 * Public: Yes
*/

params [["_injuryLevel", 0]];

private _level = (_injuryLevel max 0) min 4;

// [minCount, maxCount, minSeverity, maxSeverity, bleedProbability] per DESIGN.md §4.4
private _profiles = [
    [1, 1, 0.1, 0.3, 0.2],
    [1, 2, 0.2, 0.5, 0.5],
    [2, 3, 0.4, 0.7, 0.8],
    [3, 4, 0.6, 0.9, 0.8],
    [4, 6, 0.8, 1.0, 0.95]
];
private _profile = _profiles select _level;
_profile params ["_minCount", "_maxCount", "_minSeverity", "_maxSeverity", "_bleedChance"];

// 6 regions, a direct 1:1 match to ACE3's own real body parts (DESIGN.md §4.1 / INJURY_CODES.md
// §1) - deliberately kept this simple rather than a finer anatomical breakdown.
private _limbs = ["head", "chest", "leftArm", "rightArm", "leftLeg", "rightLeg"];
private _woundTypes = ["gunshot", "shrapnel", "blast"];
// Only the 4 limbs are tourniquetable - never head/chest.
private _tourniquetableLimbs = ["leftArm", "rightArm", "leftLeg", "rightLeg"];

private _count = _minCount + floor (random ((_maxCount - _minCount) + 1));
private _usedLimbs = [];
private _injuries = [];

for "_i" from 1 to _count do {
    private _availableLimbs = _limbs - _usedLimbs;
    if (_availableLimbs isEqualTo []) then { _availableLimbs = _limbs; };
    private _limb = selectRandom _availableLimbs;
    _usedLimbs pushBackUnique _limb;

    private _bleeding = (random 1) < _bleedChance;
    private _bleedRate = if (_bleeding) then { 0.1 + random 0.3 } else { 0 };

    private _injury = createHashMap;
    _injury set ["limb", _limb];
    _injury set ["woundType", selectRandom _woundTypes];
    _injury set ["severity", _minSeverity + random (_maxSeverity - _minSeverity)];
    _injury set ["bleeding", _bleeding];
    _injury set ["bleedRate", _bleedRate];
    _injury set ["tourniquetable", _limb in _tourniquetableLimbs];
    _injury set ["variables", createHashMap];

    _injuries pushBack _injury;
};

_injuries
