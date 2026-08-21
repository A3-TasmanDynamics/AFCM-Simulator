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
simulator script (`med_sim.sqf`, not part of this repo — the full file was reviewed, not just
fragments) rather than taken on faith from the wiki alone:

- `[_unit, _damage, _hitpoint, _damageType] call ace_medical_fnc_addDamageToUnit` — hitpoint
  strings used in practice: `"Head"`, `"Body"`, `"LeftArm"`, `"RightArm"`, `"LeftLeg"`,
  `"RightLeg"` — matches DESIGN.md §4.1's `LimbId` → ACE3 hitpoint table. Damage type used
  interchangeably for the same head wound across commented-out alternates: `"shell"`, `"grenade"`,
  `"explosive"` — consistent with all three being real `ACE_Medical_Injuries.hpp` classes, not a
  sign any one is specifically "correct" for head trauma
- `[_unit, true] call ace_medical_fnc_setUnconscious`
- **Both** `[_unit, _painLevel] call ace_medical_status_fnc_adjustPainLevel` **and** the direct
  `_unit setVariable ["ace_medical_pain", _painLevel, true]` are used together in the same preset
  (set to `0.6` directly, then `adjustPainLevel` called with `0.7` afterward) — the prototype
  doesn't rely on just one mechanism; exact interaction between a direct pain set and a subsequent
  `adjustPainLevel` call isn't confirmed (i.e. whether the latter is additive on top of the former
  or simply overrides it), only that both were used together in working code
- A real, non-obvious gotcha: injuries applied immediately on `createUnit` didn't take reliably —
  the working prototype deferred injury application by 1 second via `[{...}, [_unit, ...], 1] call
  CBA_fnc_waitAndExecute`, letting the unit's medical state initialize first

### ACE Interaction Menu — confirmed, not currently used by this repo

Not part of AFCM-Simulator's own architecture (`ui`'s dialogs are native `RscDisplay`, not the ACE
self/object-interaction menu — [DESIGN.md §2.4](DESIGN.md#24-decision)), but real, confirmed API
worth recording since the prototype used it to trigger the whole medical-simulator menu from a
placed object (a laptop). Relevant if a future feature ever wants an ACE-interaction-menu entry
point (e.g. right-click a patient to open the injury dialog) as an alternative trigger alongside
the Zeus/Eden modules:

- `ace_interact_menu_fnc_createAction` — builds one menu action. Real positional args seen in
  practice: `[id, displayText, icon, statement (code, `params ["_target", "_player", "_params"]`),
  condition (code), insertChildren (code), extraParams (array), positionOffset (array), showDisabled
  (number)]`
- `ace_interact_menu_fnc_addActionToObject` — attaches a built action to an object at a given menu
  path: `[_targetObject, 0, ["ACE_MainActions"], _action]` for a top-level entry,
  `[_targetObject, 0, ["ACE_MainActions", "medSimulator"], _action]` for a submenu nested under a
  previously-created action with id `"medSimulator"` — path segments are action ids, not display
  text

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

**Resolved**: whether KAT has its own equivalent of `ace_medical_fnc_addDamageToUnit` — it doesn't,
because it doesn't need one. Confirmed directly from KAT's real source
(`addons/breathing/ACE_Medical_Injuries.hpp`, `addons/chemical/ACE_Medical_Injuries.hpp` — verified
independently via `raw.githubusercontent.com`, not just the GitHub API): KAT registers additional
wound handlers and a custom damage type into ACE3's own real `ACE_Medical_Injuries` config tree
(the same one documented above), rather than replacing ACE's damage-application API. Practically,
this means `ace_medical_fnc_addDamageToUnit`/`ace_medical_fnc_addWound` — the exact same calls
`afcm_sim_ace_compat` uses — are very likely the correct calls under KAT too, with KAT's own systems
(pneumothorax, tamponade, chemical burns) triggering automatically as a side effect. Full writeup:
[KAT_COMPAT.md §3](addons/KAT_COMPAT.md#3-the-real-finding-kat-extends-aces-wound-pipeline-it-doesnt-replace-it).

Two adjacent pieces are confirmed from the same working prototype used for the ACE3 section above
(not an official source, same caveat as before), now doubly confirmed for the fracture-array
indexing (see KAT_COMPAT.md §4):

- `_unit setVariable ["kat_surgery_fractures", _array, true]` — a 6-element array, one entry per
  limb, indexed identically to ACE's own `ALL_BODY_PARTS`: `0` = Head, `1` = Body, `2` = LeftArm,
  `3` = RightArm, `4` = LeftLeg, `5` = RightLeg — confirmed via KAT's real
  `addons/surgery/functions/fnc_fractureCheck.sqf`, which indexes this array with
  `ALL_BODY_PARTS find toLower _bodyPart`. Per-limb **severity value** (from the full prototype's
  own in-file comment, not just the array shape): `0` = Unaffected, `1` = Stable Fracture, `2` =
  Compound Fracture, `3` = Comminuted Fracture, `2.1`/`3.1` = Open Fracture, `2.2`/`3.2` = Prepared
  Fracture, `2.5` = Irrigated Fracture, `3.5` = Clamped Fracture — a real severity/treatment-stage
  scale, not a boolean per limb
- `_unit setVariable ["kat_breathing_pneumothorax", _severity, true]`,
  `"kat_breathing_Hemopneumothorax"`, `"kat_breathing_Tensionpneumothorax"` (booleans) — followed
  by `[_unit] call kat_breathing_fnc_handleBreathing` to actually apply the state; setting the
  variables alone was not sufficient in the working prototype

`afcm_sim_kat_compat` now registers as a real backend (priority 15, above `ace_compat`'s 10) since
its `requiredAddons` gate is real — it was previously kept as a non-registering stub specifically
because the class name wasn't confirmed; that's resolved. `applyInjury`/`removeInjury` are still
logging stubs in code, but the specific research blocker that justified that (no known KAT
equivalent of `ace_medical_fnc_addDamageToUnit`) is now resolved too — see
[KAT_COMPAT.md](addons/KAT_COMPAT.md) for the full writeup and what's still actually open.

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
