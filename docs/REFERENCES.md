<div align="center">

<img src="assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../README.md) · [Design](DESIGN.md) · **References** · [Addons](addons/README.md) · [Injury Codes](INJURY_CODES.md)

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

## ACE3 medical source (confirmed directly from acemod/ACE3, not the wiki)

The wiki documents `ace_medical_fnc_addDamageToUnit` and `ace_medical_fnc_addWound` by name but not
their real internals or exact string requirements — pulled the real source via `gh api` to ground
`afcm_sim_ace_compat`'s injury/bleeding logic exactly, rather than guessing from the docstrings.

- **`addons/medical/functions/fnc_addDamageToUnit.sqf`** — real signature:
  `[_unit, _damageToAdd, _bodyPart, _typeOfDamage, _instigator, _unused, _overrideInvuln] call
  ace_medical_fnc_addDamageToUnit`. Lowercases `_bodyPart` internally before matching against
  `ALL_BODY_PARTS`, so `"Head"`/`"head"` etc. both work. Requires `local _unit`. Internally fires a
  `CBA_fnc_localEvent` (`ace_medical_woundReceived`) that ACE's own wound-selection logic (below)
  turns into a *random* wound per the chosen `_typeOfDamage`'s weighting table — it does not create
  a specific, predictable wound.
- **`addons/medical_damage/ACE_Medical_Injuries.hpp`** — the real wound/damage-type config.
  Confirmed real wound classes (case-sensitive, used by `addWound` below): `Abrasion`, `Avulsion`,
  `Contusion`, `Crush`, `Cut`, `Laceration`, `VelocityWound`, `PunctureWound`, `ThermalBurn`.
  Confirmed real `damageTypes` classes (what `_typeOfDamage` must be): `bullet`, `grenade`,
  `explosive`, `shell`, `vehiclehit`, `vehiclecrash`, `collision`, `falling`, `backblast`, `stab`,
  `punch`, `ropeburn`, `drowning`, `fire`, `burn`, `unknown` — confirms `afcm_sim_ace_compat`'s
  existing `gunshot→bullet`/`shrapnel→grenade`/`blast→shell` mapping was already using real classes.
- **`addons/medical/functions/fnc_addWound.sqf`** — a separate, lower-level real function the wiki
  page doesn't explain: `[_unit, _bodyPart, [_woundType, _amountOf, _size, _woundDamage]] call
  ace_medical_fnc_addWound`. Unlike `addDamageToUnit`, `_bodyPart` here is **not** lowercased
  internally — it must already be one of the exact `ALL_BODY_PARTS` strings
  (`"head"`/`"body"`/`"leftarm"`/`"rightarm"`/`"leftleg"`/`"rightleg"`, confirmed from
  `addons/medical_engine/script_macros_medical.hpp`) or the lookup silently fails to match.
  `_woundType` must exactly match a real wound class name above. `_size` (0/1/2) scales that wound
  class's own `bleeding`/`pain` config values — it's the only lever this function gives over
  bleeding severity. Used in `afcm_sim_ace_compat` to deterministically guarantee a bleeding wound
  when the Injury object says `bleeding: true`, since `addDamageToUnit` alone leaves that to chance.

## KAT - Advanced Medical (KAM) — official sources, now confirmed

Previously "no official documentation found" — resolved. KAT's real project is **KAM**
(KAT-Advanced-Medical/KAM on GitHub), with an official wiki and a GitBook docs site.

| Source | Use for |
|---|---|
| [GitHub — KAT-Advanced-Medical/KAM](https://github.com/KAT-Advanced-Medical/KAM) | The mod's actual repo. Confirms: HEMTT-built, GPL 3.0, requires **CBA_A3 3.16.0+** and **ACE3 3.16.1+** (built as an ACE3 medical extension, not standalone). Confirmed real addon folders (bare names, `kat` project prefix, same convention this repo uses — see DESIGN.md §7): `main`, `airway`, `breathing`, `chemical`, `circulation`, `feedback`, `gui`, `hypothermia`, `misc`, `ophthalmology`, `pharma`, `stretcher`, `surgery`, `vitals`, `watch`, `zeus` (+ an optional `compat_rhs_usf3`) — so the real `CfgPatches` root is **`kat_main`**, now used in `afcm_sim_kat_compat`'s `requiredAddons` |
| [GitHub wiki](https://github.com/KAT-Advanced-Medical/KAM/wiki) | Classnames, KAM Injuries & Complications, KAM Injuries code snippets, KAM Items, KAT Settings. The Classnames page (fetched via raw wiki content) gave real confirmed item classes: `kat_bloodIV_A`/`_B`/`_AB`/`_O` (+ `_250`/`_500`/`_N` volume variants), `kat_AED`/`kat_X_AED`, `kat_IO_FAST`, `kat_IV_16`, pharmacology items `kat_ketamine`, `kat_fentanyl`, `kat_atropine`, `kat_amiodarone`, `kat_naloxone`, `kat_nitroglycerin`, `kat_TXA`, surgical `kat_clamp`/`kat_plate`/`kat_retractor`/`kat_scalpel`, and `kat_stretcherBag`/`Attachable_Helistretcher`. The Injuries/Settings pages exist but returned placeholder or thin content when checked — still not confirmed |
| [GitBook — KAM Docs](https://kam-1.gitbook.io/kam-docs) | Clinical-doctrine-style documentation, not a code reference: airway/breathing management, cardiac arrest + AED protocol, fluids/blood-type compatibility, kidney function and acidosis, coagulation/clotting, surgery/fracture care, chemical warfare, an "essential values" appendix, and a full aid-procedure walkthrough. Notably covers **acidosis and coagulation** as distinct systems — worth a look for AFCM's own Lethal Triad Engine (AFCM DESIGN.md §2.1), as an existing example of how another Arma medical mod models the same physiology, independent of AFCM's own sourcing |

**Still not confirmed**: the actual wound/injury-application function — KAT's equivalent of
`ace_medical_fnc_addDamageToUnit`. Two adjacent pieces are confirmed from the same working
prototype used for the ACE3 section above (not an official source, same caveat as before):

- `_unit setVariable ["kat_surgery_fractures", _array, true]` — a 6-element array, one entry per
  limb; confirmed indices in practice: `2` = LeftArm, `3` = RightArm, `4` = LeftLeg, `5` = RightLeg
  (indices `0`/`1` unconfirmed — likely Head/Body, always `0` in the examples seen)
- `_unit setVariable ["kat_breathing_pneumothorax", _severity, true]`,
  `"kat_breathing_Hemopneumothorax"`, `"kat_breathing_Tensionpneumothorax"` (booleans) — followed
  by `[_unit] call kat_breathing_fnc_handleBreathing` to actually apply the state; setting the
  variables alone was not sufficient in the working prototype

`afcm_sim_kat_compat` now registers as a real backend (priority 15, above `ace_compat`'s 10) since
its `requiredAddons` gate is real — it was previously kept as a non-registering stub specifically
because the class name wasn't confirmed; that's resolved. `applyInjury`/`removeInjury` are still
logging stubs pending the actual wound-application call.

## Zeus/Curator module categorization (official wiki + confirmed via KAT's real config)

Two real, in-game bugs traced back to this: the "AFCM Medical Simulator" category never appeared
in the Zeus CREATE panel despite the modules loading cleanly with no config errors.

| Source | Use for |
|---|---|
| [Modules](https://community.bistudio.com/wiki/Modules) | Confirms `CfgFactionClasses` is the real category mechanism for modules, not `CfgVehicleClasses` — a module's `category` value must name a `CfgFactionClasses` class, and `BIS_fnc_initModules` groups modules into the Zeus/Eden module browser by `CfgFactionClasses` entries whose `side` equals `sideLogic` |
| [Arma 3: Curator](https://community.bistudio.com/wiki/Arma_3:_Curator) / [BIS_fnc_moduleCurator](https://community.bistudio.com/wiki/BIS_fnc_moduleCurator) | Curator-specific module display/access plumbing |
| [T167804](https://feedback.bistudio.com/T167804) | `fn_initModules` creates a group per `CfgFactionClasses` entry — corroborates the above |

Two distinct, additive gotchas, both required together:

1. **`scopeCurator = 2;`** on the `Module_F`-derived class itself. `scope = 2;` alone is enough for
   the module to appear in the **Eden** (2D editor) object browser, but Zeus has its own separate
   visibility gate — without `scopeCurator = 2;`, the module compiles and registers fine but never
   appears in the Zeus curator browser at all.
2. **`CfgFactionClasses`, not `CfgVehicleClasses`, plus a matching `side` on the module class.**
   `CfgVehicleClasses` is what the **Eden** "Add Object" browser groups by — it does nothing for
   Zeus. Zeus groups modules by `CfgFactionClasses` entries, matched via each module's own `side`.
   `side = 7` (`sideLogic`) is the neutral side that always shows regardless of the mission's actual
   side setup — confirmed as the real value in practice by diffing against KAT's own
   `addons/zeus/config.cpp` (`class GVAR(baseModule): Module_F { side=7; ... }`,
   `class CfgFactionClasses { class GVAR(KAM) { side = 7; }; };`), which is exactly how KAT's own
   always-visible "KAM" Zeus category is implemented.

Both `afcm_sim_zeus/config.cpp` and `afcm_sim_eden/config.cpp` (the latter's modules also set
`scopeCurator = 2;` so they're Zeus-placeable) declare a `CfgFactionClasses` category with
`side = 7` and set `side = 7;` on each module class, in addition to the existing `scopeCurator = 2;`.
The `CfgFactionClasses` class name (`AFCM_SIM_Category`) is identical in both files — Arma merges
same-named config classes across addons, and without a shared name each file's declaration produced
its own separate Zeus category, both labelled "AFCM Medical Simulator" (confirmed as a real
in-game symptom, not just a theoretical risk).

## Vanilla unconscious state (official wiki)

| Source | Use for |
|---|---|
| [setUnconscious](https://community.bistudio.com/wiki/setUnconscious) | `unit setUnconscious set` (Boolean, no return value) — vanilla engine command, not ACE/KAT-specific, confirmed still present in Arma 3. Used in `afcm_sim_spawner_fnc_spawnPatient` so spawned patients are always unconscious even with no medical backend registered at all (DESIGN.md §2.5) |

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
