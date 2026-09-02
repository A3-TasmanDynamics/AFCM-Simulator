<div align="center">

<img src="assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../README.md) · [Design](DESIGN.md) · [References](REFERENCES.md) · [Addons](addons/README.md) · **Injury Codes** · [Changelog](changelogs/README.md)

</div>

# Injury Coding Reference

**Tasman Dynamics** — the backend-agnostic vocabulary AFCM-Simulator uses to describe an injury,
plus how each real backend currently maps it. This doc consolidates
[DESIGN.md §4](DESIGN.md#4-data-model) (the schema itself) with the real, confirmed mapping tables
in [ACE_COMPAT.md](addons/ACE_COMPAT.md) and [REFERENCES.md](REFERENCES.md) — read those for the
*why*; this is the *what*, in one place.

Everything the scenario/randomizer/preset layer produces is expressed only in the vocabulary below.
`afcm_sim_scenario` and `afcm_sim_spawner` never see an ACE3 hitpoint, a KAT wound variable, or an
AFCM site directly — only whichever backend is active (§2.5) translates these codes into its own
real API, inside its own compat addon.

---

## 1. Body Parts — `LimbId`

6 values, defined in [DESIGN.md §4.1](DESIGN.md#41-body-limb-selection) — a direct 1:1 match to
ACE3's own 6 real body parts, deliberately. A finer 13-region anatomical breakdown (splitting chest
from abdomen, upper arm from forearm, etc.) was built and then reverted in favour of this simpler
scheme.

| `LimbId` | Real-world region | `afcm_sim_ace_compat` target |
|---|---|---|
| `head` | Head | `"head"` |
| `chest` | Chest/torso | `"body"` |
| `leftArm` | Left arm | `"leftarm"` |
| `rightArm` | Right arm | `"rightarm"` |
| `leftLeg` | Left leg | `"leftleg"` |
| `rightLeg` | Right leg | `"rightleg"` |

**Status**: `afcm_sim_ace_compat`'s column is real and confirmed — see
[ACE_COMPAT.md §4.1](addons/ACE_COMPAT.md#41-limbid--ace3-body-part) for the source.
`afcm_sim_kat_compat` uses the identical mapping (KAT sits on the same 6 ACE body parts underneath
— [KAT_COMPAT.md §3](addons/KAT_COMPAT.md#3-the-real-finding-kat-extends-aces-wound-pipeline-it-doesnt-replace-it)).
`acm_compat` doesn't have a confirmed mapping yet (`applyInjury` is still a stub). No native
`afcm_compat` backend at this stage — there's no AFCM to target yet; an earlier empty config-only
stub was removed rather than kept as scaffolding pointing at nothing (DESIGN.md §9).

`tourniquetable` (§2) is only ever `true` for `leftArm`/`rightArm`/`leftLeg`/`rightLeg` — never
`head`/`chest`.

> Note the casing difference from ACE3's own API: `ace_medical_fnc_addDamageToUnit` accepts
> `"Head"`/`"Body"`/`"LeftArm"`/etc. (it lowercases internally), but
> `ace_medical_fnc_addWound` does **not** — it requires the exact lowercase forms shown above. See
> [ACE_COMPAT.md §3](addons/ACE_COMPAT.md#3-why-two-ace-calls-not-one) for the full explanation.

---

## 2. The `Injury` Object

The unit of authoring — one `Injury` = one wound at one limb. A preset or the randomizer produces
an array of these; they're applied one at a time via `afcm_sim_fnc_backend_applyInjury`.
Defined in [DESIGN.md §4.2](DESIGN.md#42-injury-object).

| Field | Type | Meaning |
|---|---|---|
| `limb` | `LimbId` | Where — one of the six values in §1 |
| `woundType` | `String` | What kind — backend-agnostic classification, see §3 |
| `severity` | `Number`, `0.0`–`1.0` | Initial trauma magnitude at time of application |
| `bleeding` | `Bool` | Whether this injury should produce an active hemorrhage |
| `bleedRate` | `Number` | Seed value only — whichever backend is active derives the *actual* ongoing rate from its own model. Not authoritative once a backend starts simulating |
| `tourniquetable` | `Bool` | Derived from `limb` (arms/legs only), not authored per-injury |
| `variables` | `HashMap` | Free-form key/value for custom presets (e.g. `"fracture": true`) — not consumed anywhere yet |

### 2.1 Real values in use today

`woundType` is an open vocabulary in principle, but only three values are actually produced or
consumed anywhere in the codebase right now (`afcm_sim_scenario_fnc_randomizeInjuries` is the only
producer; `afcm_sim_ace_fnc_applyInjury` is the only real consumer):

| `woundType` | Meaning | Real ACE3 `damageTypes` class it maps to |
|---|---|---|
| `gunshot` | Ballistic/bullet wound | `bullet` |
| `shrapnel` | Fragmentation wound | `grenade` |
| `blast` | Overpressure/explosive wound | `shell` |

All three ACE3 classes are real, confirmed `ACE_Medical_Injuries.hpp` classes (not guessed) — see
[REFERENCES.md](REFERENCES.md#ace3-medical-source-confirmed-directly-from-acemodace3-not-the-wiki)
for the full class list ACE3 actually supports beyond these three (`explosive`, `vehiclehit`,
`vehiclecrash`, `collision`, `falling`, `backblast`, `stab`, `punch`, `ropeburn`, `drowning`,
`fire`, `burn`, `unknown`) — none of those are wired up on the `afcm_sim_scenario` side yet, so
they're not reachable through AFCM-Simulator today even though `ace_compat` could in principle
support any of them.

### 2.2 Bleeding → real ACE3 wound class

When `bleeding: true`, `ace_compat` forces a real, sized bleeding wound via
`ace_medical_fnc_addWound` rather than leaving it to `addDamageToUnit`'s internal randomness (full
rationale in [ACE_COMPAT.md §3](addons/ACE_COMPAT.md#3-why-two-ace-calls-not-one)). Which wound
class it uses depends on `woundType`:

| `woundType` | ACE3 wound class used |
|---|---|
| `gunshot` | `VelocityWound` |
| `shrapnel` | `PunctureWound` |
| `blast` | `PunctureWound` |

`bleedRate` (roughly `0.1`–`0.4` as produced by the randomizer, see §4 below) is bucketed into
ACE3's `_size` enum, since that's the only lever `addWound` exposes over how much a specific wound
bleeds:

| `bleedRate` | ACE3 `_size` |
|---|---|
| `< 0.15` | `0` (small) |
| `0.15`–`0.29` | `1` (medium) |
| `≥ 0.3` | `2` (large) |

### 2.3 Real ACE3 wound classes (case-sensitive)

The full set `addWound` accepts, confirmed from `ACE_Medical_Injuries.hpp` — only `VelocityWound`
and `PunctureWound` are actually used by `ace_compat` today (§2.2), the rest are documented here as
the real available vocabulary for future use:

| Class | Base bleeding | Base pain | Notes |
|---|---|---|---|
| `Abrasion` | 0.001 | 0.4 | Scrapes/rope burns |
| `Avulsion` | 0.1 | 1.0 | Torn-away tissue; causes limping |
| `Contusion` | 0 | 0.3 | Bruise — doesn't bleed |
| `Crush` | 0.05 | 0.8 | Causes limping and fracture |
| `Cut` | 0.01 | 0.1 | Minimal slicing wound |
| `Laceration` | 0.05 | 0.2 | Tearing wound, ragged edges |
| `VelocityWound` | 0.2 | 0.9 | Bullet/high-speed fragment; causes limping and fracture |
| `PunctureWound` | 0.05 | 0.4 | Nail/knife/small fragment; causes limping |
| `ThermalBurn` | 0 | 0.7 | Heat contact |

---

## 3. Injury Levels (Randomization Difficulty)

Defined in [DESIGN.md §4.4](DESIGN.md#44-injury-levels-randomization-difficulty) and implemented in
`afcm_sim_scenario_fnc_randomizeInjuries`. A level is a *profile* the randomizer rolls against, not
a fixed injury set — real values currently in the code (`[minCount, maxCount, minSeverity,
maxSeverity, bleedProbability]`):

| Level | Injury count | Severity range | Bleed probability | Notes |
|---|---|---|---|---|
| Easy | 1 | 0.1–0.3 | 20% | Single limb, non-life-threatening |
| Medium | 1–2 | 0.2–0.5 | 50% | May include one bleed |
| Hard | 2–3 | 0.4–0.7 | 80% | Multiple limbs, likely bleed |
| Extreme | 3–4 | 0.6–0.9 | 80% | Compound injuries, airway/breathing involvement *(not yet modeled — no backend touches airway state)* |
| F\*CKED! | 4–6 | 0.8–1.0 | 95% | Full MASCAL-style casualty, time-pressure case |

> **Naming note** ([TERMINOLOGY.md §2/§9](https://github.com/A3-TasmanDynamics/AFCM/blob/main/docs/TERMINOLOGY.md)):
> these five names are a gameplay-authoring difficulty scale, **not** the real T1–T4 military triage
> categories. Never let a "Hard" scenario label appear next to, or be confused with, a "T2" patient
> label.

These ranges are a starting proposal, not tuned values — a real tuning pass is still needed per
active backend (DESIGN.md §4.4), so "Hard" feels comparably hard on ACE3 vs. AFCM's own physiology
model once that backend exists.

---

## 4. Injury Preset Schema (Implemented)

Originally sketched in [DESIGN.md §4.3](DESIGN.md#43-injury-preset) as a `HashMap`; built as a
plain **`Array`** instead — a `HashMap` has no literal SQF syntax, so `str someHashMap` doesn't
produce something `call compile` can turn back into a `HashMap`. A plain `Array` of primitives
round-trips through `str`/`call compile` exactly, which is what makes copy-paste export/import work
at all:

```
Preset = [
    id,           // String
    name,         // String
    author,       // String
    description,  // String
    injuries,     // [[limb, woundType, severity, bleeding], ...] - one preset = one or more of
                  // the same 4 primitives afcm_sim_scenario_fnc_serverApplyInjury already takes
    tags          // [String], e.g. "GSW", "HE", "training-scenario-3"
]
```

`injuries` deliberately stays at this lighter shape rather than the full runtime `Injury` object
(§2) — `bleedRate`/`tourniquetable`/`variables` are all derived, not authored, and get recomputed
by `serverApplyInjury` at apply time (`afcm_sim_scenario_fnc_serverApplyPreset` just loops that
same function once per injury) rather than baked into the stored preset.

Two tiers, both real: **built-in** (`afcm_sim_scenario_fnc_getBuiltinPresets`, id prefix
`builtin_`, 5 presets shipped in the addon — GSW chest, GSW limb w/ tourniquet, blast casualty,
multiple frag wounds, a minor training laceration) and **user-saved**
(`afcm_sim_scenario_fnc_getUserPresets`/`saveUserPreset`/`deleteUserPreset`, in `profileNamespace`
— per-player, survives mission/game restarts). Export (`fnc_exportPreset.sqf`, just `str _preset`)
and import (`fnc_importPreset.sqf`, `call compile` + shape validation, always assigns a fresh id
rather than trusting the pasted one) are both real, wired into the Preset Library UI's shared
`RscEdit` text field — Export also copies straight to the OS clipboard (`copyToClipboard`).

**MCI presets are a separate, second library** — `[id, name, author, description, patientSpecs]`,
where `patientSpecs` is an Array of *these* Preset ids (or the literal string `"random"`), one per
patient in a whole incident, e.g. "HE Shell — 3 Casualties." Same shape, same
built-in/`profileNamespace`/export-import pattern, just one layer up — full detail:
[DESIGN.md § MCI Creator](DESIGN.md#5-features).

---

## 5. Per-Backend Coding Status

| Backend | `LimbId` mapping | `woundType` mapping | Bleeding | Doc |
|---|---|---|---|---|
| `ace_compat` | **Real** | **Real** (3/16+ possible classes wired) | **Real** — deterministic via `addWound` | [ACE_COMPAT.md](addons/ACE_COMPAT.md) |
| `kat_compat` | **Real** — identical fold to `ace_compat` | **Real** — identical to `ace_compat` | **Real** — identical to `ace_compat` | [KAT_COMPAT.md](addons/KAT_COMPAT.md) |
| `acm_compat` | Not confirmed | Not confirmed | Not confirmed | — |

No `afcm_compat` row — not being pursued at this stage, no AFCM to target yet (DESIGN.md §9).

---

## 6. KAT-Specific Coding — Fracture / Pneumothorax / Airway (Wired In)

KAT tracks some state that has no equivalent in the backend-agnostic `Injury` object at all — real,
KAT-internal state, not something `afcm_sim_scenario`'s randomizer or a future preset produces. An
earlier pass built this, then reverted it in favour of keeping the UI simple; it's back, this time
grounded directly against real source fetched from `KAT-Advanced-Medical/KAM` (not the prior
working prototype's comments) — full context:
[KAT_COMPAT.md §4](addons/KAT_COMPAT.md#4-confirmed-kat-specific-variables). All three are exposed
in the injury editor UI, shown only when KAT is the active backend — Fracture also only when at
least one selected limb is an arm or a leg (deliberately excludes head/chest, see below),
Pneumothorax also only when "chest" is among the selected limbs (it's torso-wide, not per-limb),
Airway also only when "head" is among the selected limbs (it's head/neck-wide, not per-limb) —
`afcm_sim_kat_fnc_applyFracture`/`applyPneumothorax`/`applyAirway`, called directly rather than
through the generic `Injury`/backend-interface dispatch, since none of the three fit that schema.

**Fracture severity** (`kat_surgery_fractures`) is a 6-element array, one entry per limb — and each
entry is a **severity/treatment-stage scale, not a boolean**. This array's own index order is
**KAT/ACE's** 6 body parts (`head, torso, leftArm, rightArm, leftLeg, rightLeg`) — the exact same 6
values AFCM-Simulator's own `LimbId` (§1) uses 1:1, so `afcm_sim_kat_fnc_applyFracture` is a direct
index lookup, no `LimbId` → ACE body-part folding needed at all. **AFCM-Simulator's own UI/server
dispatch (`fnc_serverApplyKatFracture.sqf`) deliberately only allows arms/legs**, not head/chest,
even though the real array has a slot for both — a scope choice to keep this UI focused on the
limb-fracture/tourniquet-and-splint training case, not a limitation of KAT's actual data model:

```sqf
/*
Fracture severity scale (kat_surgery_fractures per-limb value) - confirmed directly from
addons/surgery/functions/fnc_fractureSelectLocal.sqf's own comparison logic:
0 = None, 1 = Simple Fracture, 2 = Compound Fracture, 3 = Comminuted Fracture,
2.1/3.1 = Open Fracture, 2.2/3.2 = Prepared Fracture, 2.5 = Irrigated Fracture, 3.5 = Clamped Fracture
(the `.1`/`.2`/`.5` treatment-progress substages still read as their base severity under
fractureSelectLocal's own `_liveFracture >= 2 && < 3` style comparisons)

Array index -> limb: [head, torso, leftArm, rightArm, leftLeg, rightLeg]
*/

[patientUnit, "leftArm", 1] call afcm_sim_kat_fnc_applyFracture;  // Simple fracture, left arm
[patientUnit, "rightArm", 2] call afcm_sim_kat_fnc_applyFracture; // Compound fracture, right arm
[patientUnit, "leftLeg", 3] call afcm_sim_kat_fnc_applyFracture;  // Comminuted fracture, left leg
```

The injury editor's own UI combo only offers the 4 base severities (None/Simple/Compound/
Comminuted) — the `.1`/`.2`/`.5` treatment-progress substages are something KAT's own surgery
workflow advances a patient *to* during treatment, not a sensible "starting" injury an instructor
would author.

**Pneumothorax** (`kat_breathing_pneumothorax`) is a `Number` severity on a **confirmed 0-4 scale**
— fetched directly from `addons/breathing/functions/fnc_handleBreathing.sqf`
(`_pneumothorax / 4` in its own breathing-rate calculation) and
`fnc_inflictAdvancedPneumothorax.sqf` (KAT's own real infliction function sets it to exactly `4`
for any advanced case), alongside two **mutually-exclusive** booleans
(`kat_breathing_hemopneumothorax`, `kat_breathing_tensionpneumothorax` — confirmed mutually
exclusive from that same real infliction function). All three set via `setVariable`, then
`[_unit] call kat_breathing_fnc_handleBreathing` to actually apply the state — setting the
variables alone isn't sufficient. `afcm_sim_kat_fnc_applyPneumothorax` exposes this as a single UI
choice — None / Simple Pneumothorax / Hemopneumothorax / Tension Pneumothorax — rather than three
independent controls, since the real combinations that make clinical sense are limited, and is
deliberately deterministic unlike KAT's own real infliction function, which rolls a random chance
and a random hemo-vs-tension split — an instructor picking a type should get exactly that, not a
dice roll. Severity is `2` for Simple, `4` for Hemo/Tension — an earlier pass gave Simple the same
`4` as the advanced cases too, contradicting `handleBreathing`'s own continuous `_pneumothorax / 4`
scaling (KAT has no real "basic pneumothorax" infliction function of its own to confirm an exact
number against, only the advanced path exists in its source, so `2` is a reasonable mid-scale pick,
not a confirmed KAT constant). Unlike Fracture, this isn't per-limb — it's a torso-wide condition.
`kat_breathing_fnc_handleBreathing`/`kat_circulation_fnc_updateInternalBleeding` (below) are
dispatched via a CBA event targeting the unit (`CBA_fnc_targetEvent`) rather than called directly —
the same real locality fix `afcm_sim_ace_fnc_applyInjury` uses (INJURY_CODES.md §2, ACE_COMPAT.md).

**Hemothorax and "blood volume in the chest":** picking Hemopneumothorax now also calls the real
`kat_circulation_fnc_updateInternalBleeding` (an earlier pass missed this — the flag was being set
with no actual bleeding effect). That function turns the flag into a live internal-bleeding rate
(`kat_circulation_internalBleeding`, litres/second) that drains the patient's real, whole-body
**`ace_medical_bloodVolume`** (litres, default 6.0 — KAT extends ACE3's own blood volume tracking,
same as everything else in §3 above). **There is no separate "chest cavity" blood pool in KAT's
real source** — despite how a hemothorax gets described casually ("bleeding into the chest"), the
mod models it as one whole-body volume draining faster, not a second, chest-scoped one. Both new
fields are exposed in the injury editor's live status readout (`afcm_sim_kat_fnc_getState`) whenever
KAT is active — Blood Volume always, Internal Bleeding Rate only while it's actually nonzero.

**Airway** (`kat_airway_obstruction` / `kat_airway_occluded`) — two **mutually-exclusive** Bools,
confirmed from `addons/airway/functions/fnc_checkAirway.sqf` and
`fnc_treatmentAdvanced_airwayLocal.sqf`, with genuinely different real treatment paths rather than
two severities of the same thing:

```sqf
/*
Airway state (kat_airway_obstruction / kat_airway_occluded) - confirmed directly from
addons/airway/functions/fnc_treatmentAdvanced_airwayLocal.sqf's own treatment logic:
Obstruction - clearable by inserting a real airway adjunct (Larynxtubus/i-gel/OPA), which sets
  obstruction back to false.
Occlusion - NOT clearable that way - the treatment function explicitly rejects the item (returned
  to the medic's inventory unused) whenever occluded is true. Models something an airway adjunct
  physically can't fix (e.g. a crushed/destroyed airway), needing a real surgical airway KAT
  doesn't otherwise model with an item.
*/

[patientUnit, 1] call afcm_sim_kat_fnc_applyAirway; // Obstruction
[patientUnit, 2] call afcm_sim_kat_fnc_applyAirway; // Occlusion
```

`afcm_sim_kat_fnc_applyAirway` sets the variables directly with no companion "apply the state" call
— unlike Pneumothorax, neither variable drives a derived physiological rate the way pneumothorax
severity feeds `handleBreathing`'s math, and `kat_airway_fnc_handleAirway` is KAT's own *random*
infliction roll, not a state-application function, so it would be wrong to call here. Like
Pneumothorax, this isn't per-limb — it's a head/neck-wide condition, shown in the UI only when
"head" is among the selected limbs.

---

## 7. Cardiac State — Shared (ACE + KAT), Not KAT-Specific

Unlike §6, cardiac arrest is **genuinely ACE-native**, not a KAT invention — confirmed directly
from `acemod/ACE3`'s own source (`addons/medical_status/functions/fnc_setCardiacArrestState.sqf`,
`addons/medical_engine/script_macros_medical.hpp`'s `IN_CRDC_ARRST` macro), and doubly confirmed
from KAT's own repo, which vendors a copy of that exact same ACE header (`include/z/ace/addons/
medical_engine/script_macros_medical.hpp`) rather than defining its own arrest flag — KAT's vitals
loop reads the identical real variable. That's why `afcm_sim_ace_fnc_applyCardiacState` exists at
all, unlike Fracture/Pneumothorax/Airway which only exist under `kat_compat`.

**Base arrest** (`ace_medical_vitals_inCardiacArrest`, `Bool`) — set via the real
`ace_medical_status_fnc_setCardiacArrestState`, which also zeroes heart rate (or restores it to 40
on revival), forces unconsciousness when entering arrest, and fires a real CBA local event
(`"ace_cardiacArrest"`). `afcm_sim_ace_fnc_reset`/`afcm_sim_kat_fnc_reset` (`ace_medical_fnc_fullHeal`)
already correctly exit cardiac arrest as a side effect — confirmed from ACE3's own
`fnc_fullHealLocal.sqf` source, which fires a real `"ace_medical_CPRSucceeded"` local event
whenever `IN_CRDC_ARRST` is true, rather than setting the flag directly (that line is deliberately
commented out in ACE's own source — "this should be set by statemachine transition").

**Rhythm type** (`kat_circulation_cardiacArrestType`, `Number`) — real, KAT-only detail layered on
top of the shared base flag, doubly confirmed from KAT's own
`addons/circulation/functions/fnc_handleCardiacArrest.sqf` and
`fnc_getCardiacArrestHeartRate.sqf` (both fetched directly, their own in-file comments agree):

```sqf
/*
Cardiac rhythm scale (kat_circulation_cardiacArrestType) - confirmed directly from
addons/circulation/functions/fnc_handleCardiacArrest.sqf's own in-file comment:
0 = Normal, 1 = Asystole (no pulse, not shockable), 2 = Pulseless Electrical Activity
(AEDX fake pulse, not shockable), 3 = Ventricular Fibrillation (shockable),
4 = Ventricular Tachycardia (shockable)
*/

[patientUnit, 1] call afcm_sim_kat_fnc_applyCardiacState; // Asystole
[patientUnit, 3] call afcm_sim_kat_fnc_applyCardiacState; // Ventricular Fibrillation
```

`afcm_sim_kat_fnc_applyCardiacState` sets `ace_medical_vitals_inCardiacArrest` (true for any
non-zero rhythm) *and* `kat_circulation_cardiacArrestType` together, with no companion "apply the
state" call needed — both real KAT consumers read the rhythm variable fresh on their own periodic
schedule (same as Airway, unlike Pneumothorax's `handleBreathing` requirement). Only has a visible
effect on the *rhythm* if the mission has KAT's own "Advanced Cardiac Rhythm" setting
(`kat_circulation_AdvRhythm`) enabled — the base arrest flag (and its unconsciousness/heart-rate
effects) works regardless, since that part is pure ACE. Deliberately deterministic, unlike KAT's
own real `fnc_handleCardiacArrest.sqf` (which rolls a random chance, a random rhythm split, and a
time-based random deterioration cascade) — an instructor picking a rhythm here should get exactly
that, not a dice roll or a later automatic downgrade to a worse rhythm.

`afcm_sim_kat_fnc_reset` also clears `kat_circulation_cardiacArrestType` back to `0` explicitly —
`ace_medical_fnc_fullHeal` has no knowledge of this KAT-only variable and can't clear it, same class
of gap as `kat_surgery_fractures`/`kat_breathing_pneumothorax`/`kat_airway_obstruction` before it.

Exposed in the injury editor as a single **Cardiac State** combo, shown for either backend, gated
on **"chest"** being among the selected limbs — same gating as Pneumothorax, even though the real
`ace_medical_vitals_inCardiacArrest` flag is actually whole-patient, since chest is where an
instructor thinks to look for it. Under ACE it offers only None/Cardiac Arrest (no rhythm concept
exists); under KAT it offers the full five-value rhythm enum above.

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
