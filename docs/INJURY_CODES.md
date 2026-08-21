<div align="center">

<img src="assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../README.md) · [Design](DESIGN.md) · [References](REFERENCES.md) · [Addons](addons/README.md) · **Injury Codes**

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

13 values, defined in [DESIGN.md §4.1](DESIGN.md#41-body-limb-selection) — real anatomical regions,
not just ACE3's 6 hitpoints, so a casualty assessment can tell chest trauma from abdominal trauma,
or an upper-arm wound from a forearm one.

| `LimbId` | Real-world region | `afcm_sim_afcm_compat` target | `afcm_sim_ace_compat` target |
|---|---|---|---|
| `head` | Head | AFCM head site | `"head"` |
| `neck` | Neck | AFCM torso site | `"body"` |
| `chest` | Chest | AFCM torso site | `"body"` |
| `abdomen` | Abdomen | AFCM torso site | `"body"` |
| `pelvis` | Pelvis / hips | AFCM torso site | `"body"` |
| `upperArmLeft` | Left shoulder-to-elbow | AFCM left-arm site | `"leftarm"` |
| `forearmLeft` | Left elbow-to-hand | AFCM left-arm site | `"leftarm"` |
| `upperArmRight` | Right shoulder-to-elbow | AFCM right-arm site | `"rightarm"` |
| `forearmRight` | Right elbow-to-hand | AFCM right-arm site | `"rightarm"` |
| `thighLeft` | Left hip-to-knee | AFCM left-leg site | `"leftleg"` |
| `shinLeft` | Left knee-to-foot | AFCM left-leg site | `"leftleg"` |
| `thighRight` | Right hip-to-knee | AFCM right-leg site | `"rightleg"` |
| `shinRight` | Right knee-to-foot | AFCM right-leg site | `"rightleg"` |

**Status**: `afcm_sim_afcm_compat`'s column is planned, not real yet (§9 — deferred stub, no AFCM
API to target). `afcm_sim_ace_compat`'s column is real and confirmed — see
[ACE_COMPAT.md §4.1](addons/ACE_COMPAT.md#41-limbid--ace3-body-part) for the source. `kat_compat`
and `acm_compat` don't have a confirmed mapping yet (`applyInjury` is still a stub for both).

ACE3 itself only tracks 6 real body parts, so five of the 13 `LimbId`s above (`neck`/`chest`/
`abdomen`/`pelvis`, all folding to `"body"`, plus each limb's two segments folding to one ACE part)
collapse when `ace_compat` applies them — that granularity is only meaningful to AFCM-Simulator's
own scenario layer and (once built) AFCM's native backend, not to ACE3.

`tourniquetable` (§2) is only ever `true` for the 8 limb-segment values
(`upperArmLeft`/`forearmLeft`/`upperArmRight`/`forearmRight`/`thighLeft`/`shinLeft`/`thighRight`/
`shinRight`) — never for `head`/`neck`/`chest`/`abdomen`/`pelvis`.

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

## 4. Injury Preset Schema (Planned)

Defined in [DESIGN.md §4.3](DESIGN.md#43-injury-preset) — **not implemented yet**
(`afcm_sim_scenario` only has the randomizer; no preset library exists). Documented here so the
shape is settled before it's built:

```
Preset = {
    id: String,
    name: String,
    author: String,
    description: String,
    injuries: [Injury],      // one preset = one or more injuries across one or more limbs
    tags: [String]           // e.g. "GSW", "HE", "training-scenario-3"
}
```

Two tiers planned: **built-in** (shipped in the addon — gunshot wound, HE frag pattern, blast-lung)
and **user-saved** (written to mission/profile namespace, exportable/importable as plain text so
they're shareable outside the mission file).

---

## 5. Per-Backend Coding Status

| Backend | `LimbId` mapping | `woundType` mapping | Bleeding | Doc |
|---|---|---|---|---|
| `ace_compat` | **Real** | **Real** (3/16+ possible classes wired) | **Real** — deterministic via `addWound` | [ACE_COMPAT.md](addons/ACE_COMPAT.md) |
| `kat_compat` | Not confirmed | Not confirmed | Not confirmed | — |
| `afcm_compat` | Planned (table above) | Not started | Not started | — |
| `acm_compat` | Not confirmed | Not confirmed | Not confirmed | — |

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
