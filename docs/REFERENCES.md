<div align="center">

<img src="assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../README.md) · [Design](DESIGN.md) · **References**

</div>

# References

Source material for grounding `afcm_sim_ace_compat`'s implementation in ACE3's real API — no
guessed function names or signatures. Confirmed in practice against a working prior prototype
(`med_sim.sqf`, not part of this repo) before being added here.

## ACE3 medical framework (official wiki)

| Source | Use for |
|---|---|
| [Medical Framework](https://ace3.acemod.org/wiki/framework/medical-framework) | The damage-to-wounds pipeline itself — how ACE intercepts `handleDamage`, converts damage into discrete wounds via configurable wound handlers, and applies bleeding/pain. Also the explicit warning that another mod's own `handleDamage` EH will likely break ACE's handling — directly relevant to how `afcm_sim_ace_compat` must apply damage without stepping on this |
| [Medical Treatment Framework](https://ace3.acemod.org/wiki/framework/medical-treatment-framework) | Config-level treatment infrastructure — designating vehicles/facilities as medical locations, registering custom medical items (`ACE_isMedicalItem`, `ACE_Medical_Treatment_Actions`), Zeus module access and CPR behaviour variables |
| [Functions — Medical](https://ace3.acemod.org/wiki/functions/medical) | The actual callable API. Confirmed here: `ace_medical_fnc_addDamageToUnit` (apply damage to a unit, can be lethal), `ace_medical_fnc_setUnconscious`, `ace_medical_fnc_addWound`, `ace_medical_fnc_getOpenWounds`/`getBandagedWounds`, `ace_medical_fnc_isInjured`, `ace_medical_fnc_getBloodLoss`, `ace_medical_fnc_fullHeal` |
| [Functions — Medical Status](https://ace3.acemod.org/wiki/functions/medical_status) | Status/vitals-side functions, e.g. `ace_medical_status_fnc_getAllMedicationCount` (per-medication effective dose, scaled by time-to-max-effect and max time in system) — relevant once `afcm_sim_ace_compat` needs to read back a patient's current state rather than just apply damage |
| [Class Names — Medical](https://ace3.acemod.org/wiki/class-names#medical) | **Item** class names (bandages, IV fluids, medications, tourniquets, surgical kits, supply crates) — not hitpoint or wound-class names, despite the section title. Useful for stretcher/kit selection lists, not for the `LimbId` → hitpoint mapping in DESIGN.md §4.1 |

## Confirmed function usage (from a working prototype)

The functions above were cross-checked against a real, previously-working ACE3/KAT medical
simulator script (not part of this repo) rather than taken on faith from the wiki alone:

- `[_unit, _damage, _hitpoint, _damageType] call ace_medical_fnc_addDamageToUnit` — hitpoint
  strings used in practice: `"Head"`, `"Body"`, `"LeftArm"`, `"RightArm"`, `"LeftLeg"`,
  `"RightLeg"` — matches DESIGN.md §4.1's `LimbId` → ACE3 hitpoint table
- `[_unit, true] call ace_medical_fnc_setUnconscious`
- `[_unit, _painLevel] call ace_medical_status_fnc_adjustPainLevel` and the equivalent direct
  `_unit setVariable ["ace_medical_pain", _painLevel, true]`
- A real, non-obvious gotcha: injuries applied immediately on `createUnit` didn't take reliably —
  the working prototype deferred injury application by ~1s via `CBA_fnc_addPerFrameHandler` or
  `CBA_fnc_waitAndExecute`, letting the unit's medical state initialize first

## KAT - Advanced Medical (still unconfirmed — no official wiki found)

KAT variable/function usage below is from the same working prototype, **not** an official source —
KAT's own documentation wasn't located publicly (see AFCM/docs/REFERENCES.md and DESIGN.md §8 open
question #1, which already flag KAT internals as needing verification). Recorded here because it's
at least *evidence of real working usage*, stronger than nothing, but weaker than a citable source:

- `_unit setVariable ["kat_surgery_fractures", _array, true]` — a 6-element array, one entry per
  limb; confirmed indices in practice: `2` = LeftArm, `3` = RightArm, `4` = LeftLeg, `5` = RightLeg
  (indices `0`/`1` unconfirmed — likely Head/Body, always `0` in the examples seen)
- `_unit setVariable ["kat_breathing_pneumothorax", _severity, true]`,
  `"kat_breathing_Hemopneumothorax"`, `"kat_breathing_Tensionpneumothorax"` (booleans) — followed
  by `[_unit] call kat_breathing_fnc_handleBreathing` to actually apply the state; setting the
  variables alone was not sufficient in the working prototype

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
