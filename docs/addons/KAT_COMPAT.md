<div align="center">

<img src="../assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../../README.md) · [Design](../DESIGN.md) · [References](../REFERENCES.md) · [Addons Index](README.md) · [Injury Codes](../INJURY_CODES.md) · **kat_compat**

</div>

# `afcm_sim_kat_compat`

**A Tasman Dynamics Backend Module** — part of [AFCM-Simulator](../../README.md)'s soft-dependency
backend architecture (see [DESIGN.md §2.5](../DESIGN.md#25-soft-dependencies--runtime-backend-detection)).

Status: **registers as a real backend; `applyInjury`/`getState` are real, `removeInjury` is still a
stub** — see [§3](#3-the-real-finding-kat-extends-aces-wound-pipeline-it-doesnt-replace-it) for the
research that made `applyInjury` possible.
Owner: Tasman Dynamics
PBO: `afcm_sim_kat_compat.pbo` (folder: `addons/kat_compat`)
Function tag: `afcm_sim_kat`
Target: [KAT - Advanced Medical (KAM)](https://github.com/KAT-Advanced-Medical/KAM)

---

## 1. What This Addon Is

`kat_compat` implements AFCM-Simulator's backend interface (`applyInjury`/`removeInjury`/`getState`) against
**KAT - Advanced Medical** (real project name **KAM**, `kat_main` `CfgPatches` root) — the more
detailed medical overhaul many servers run instead of, or on top of, plain ACE3 medical. Same
soft-dependency mechanism as every other compat addon (see
[ACE_COMPAT.md §1.1](ACE_COMPAT.md#11-why-its-a-separate-pbo-not-an-ifdef) for the full "why a
separate PBO" reasoning) — this PBO simply never loads unless KAT is actually present.

KAT is **not** a from-scratch medical system — [confirmed from its own repo](https://github.com/KAT-Advanced-Medical/KAM),
it requires CBA_A3 3.16.0+ and **ACE3 3.16.1+**, and is built as an extension of ACE3 medical
rather than a standalone replacement. That relationship is the whole story of §3 below.

### 1.1 Requirements

```cpp
requiredAddons[] = {"cba_main", "ace_medical_engine", "kat_main", "afcm_sim_main"};
```

| Dependency | Why |
|---|---|
| `cba_main` | CBA_A3 — hard dependency of the whole mod |
| `ace_medical_engine` | KAT is built on ACE3 medical (§1), so this PBO also requires the same ACE component `ace_compat` does |
| `kat_main` | KAT's real `CfgPatches` root — confirmed via [KAT-Advanced-Medical/KAM](https://github.com/KAT-Advanced-Medical/KAM): HEMTT-built, bare addon folders (`main`, `airway`, `breathing`, `chemical`, `circulation`, `feedback`, `gui`, `hypothermia`, `misc`, `ophthalmology`, `pharma`, `stretcher`, `surgery`, `vitals`, `watch`, `zeus`) under a `kat` project prefix, same convention this repo uses |
| `afcm_sim_main` | Owns the backend interface this addon registers against |

### 1.2 Registration & Priority

Registers on `preInit` (`fnc_preInit.sqf`) at **priority 15** — above `ace_compat`'s 10, below
where `afcm_compat` will land once implemented. Rationale: a server running ACE3 **and** KAT should
get KAT's richer model, not fall back to plain-ACE3 behaviour, without either compat addon needing
to know the other exists (full registration/selection lifecycle in
[DESIGN.md §2.5](../DESIGN.md#25-soft-dependencies--runtime-backend-detection)).

| Backend | Priority | Status |
|---|---|---|
| `afcm` (native AFCM) | 20+ (planned) | Deferred stub |
| **`kat`** (this addon) | **15** | **Confirmed, registers** |
| `acm` | between ace/kat (planned) | Deferred stub |
| `ace` | 10 | Confirmed, registers — see [ACE_COMPAT.md](ACE_COMPAT.md) |

---

## 2. Function Reference

All under the `afcm_sim_kat` tag.

### `afcm_sim_kat_fnc_preInit`
Registers this backend with `afcm_sim_main` under id `"kat"`, priority 15. Real, runs automatically.

### `afcm_sim_kat_fnc_applyInjury`
**Real implementation.** Identical in substance to `afcm_sim_ace_fnc_applyInjury` — same `LimbId`
fold, same `addDamageToUnit`/`addWound` calls (§3 explains why that's correct under KAT too), same
bleeding-wound logic. Was a stub specifically because that research hadn't been done yet.

### `afcm_sim_kat_fnc_getState`
**Real implementation.** Identical in substance to `afcm_sim_ace_fnc_getState` (see
[ACE_COMPAT.md](ACE_COMPAT.md#afcm_sim_ace_fnc_getstate)) — same read-only, any-machine-safe ACE3
getters, since KAT extends the same underlying state ACE3 tracks rather than replacing it.

### `afcm_sim_kat_fnc_reset`
**Real implementation.** Identical to `afcm_sim_ace_fnc_reset` — `ace_medical_fnc_fullHeal` then
re-lock via `afcm_sim_kat_fnc_setUnconscious`. Backs the limb-select ("main") screen's Reset
Patient button — moved there from the injury editor, which now has its own purely-local
"Reset Limb" that only clears the form (DESIGN.md §5).

### `afcm_sim_kat_fnc_setUnconscious`
**Real implementation.** Identical to `afcm_sim_ace_fnc_setUnconscious` — `[_unit, true] call
ace_medical_fnc_setUnconscious`, not the engine's own `setUnconscious` command (REFERENCES.md
"Round 4" — the engine command never sets ACE's own `ACE_isUnconscious` tracking variable, which is
what `ace_medical_ai`'s state machine actually checks before letting a unit self-treat).

### `afcm_sim_kat_fnc_removeInjury`
**Stub.** No real removal call wired up yet — same open question as `ace_compat`'s.

Real `applyFracture`/`applyPneumothorax` functions (KAT-only, no ACE equivalent —
`kat_surgery_fractures`/`kat_breathing_*`) were built and then reverted along with the UI controls
that would have used them, in favour of keeping the injury editor ACE-only. Documented as
still-real, still-confirmed vocabulary in [INJURY_CODES.md §6](../INJURY_CODES.md#6-kat-specific-coding-confirmed-not-wired-into-the-ui)
if revisited.

---

## 3. The Real Finding: KAT Extends ACE's Wound Pipeline, It Doesn't Replace It

Pulled directly from KAT's real source (`KAT-Advanced-Medical/KAM` on GitHub, verified independently
via `raw.githubusercontent.com` — not just the GitHub Contents API — since one of these files reads
unusually verbosely for game-mod source and was worth double-checking).

KAT ships its own `ACE_Medical_Injuries.hpp` fragments in at least two addons, both extending the
exact same real ACE3 config tree documented in
[REFERENCES.md](../REFERENCES.md#ace3-medical-source-confirmed-directly-from-acemodace3-not-the-wiki):

**`addons/breathing/ACE_Medical_Injuries.hpp`** registers an extra wound handler on ACE's real
`bullet` damage type:
```cpp
class ACE_Medical_Injuries {
    class damageTypes {
        class woundHandlers;
        class bullet {
            class woundHandlers: woundHandlers {
                GVAR(pulmoHit) = QFUNC(woundsHandlerPulmoHit);
            };
        };
    };
};
```
`kat_breathing_fnc_woundsHandlerPulmoHit` runs whenever ACE processes bullet damage to the `"Body"`
hitpoint, rolling a chance to inflict pneumothorax/tamponade — a KAT-specific *side effect*, not a
replacement for how the damage itself gets applied.

**`addons/chemical/ACE_Medical_Injuries.hpp`** goes further and adds a wholly new damage type and
wound class (`KAT_chemicalBurn` / `KAT_ChemicalBurn`) into the same real config tree, for
chemical-warfare blister agents — its own comment explains why no extra registration step is
needed: *"ACE's `parseConfigForInjuries` (`medical_damage/functions`) walks
`configFile >> "ACE_Medical_Injuries"` at `preInit` and merges all addon contributions
automatically."*

### 3.1 What this means for `applyInjury`

**KAT does not expose its own "apply an injury" entry point to replace `ace_medical_fnc_
addDamageToUnit`/`ace_medical_fnc_addWound` — it hooks additional handlers onto ACE's real pipeline
instead.** Calling the exact same two real ACE3 functions `ace_compat` already uses (see
[ACE_COMPAT.md §3](ACE_COMPAT.md#3-why-two-ace-calls-not-one)) should apply correctly *with* KAT's
extra systems (pneumothorax, tamponade, chemical burns) triggering automatically as a side effect —
no separate KAT-specific damage call needed for the baseline case.

This resolves the specific blocker that kept `applyInjury`/`removeInjury` as stubs — it does **not**
mean `kat_compat` should stay identical to `ace_compat` forever, since KAT's own state (fractures,
pneumothorax stage, blood type) still needs KAT-specific read/write for anything beyond baseline
damage (§4) — but the core "how do I hurt this unit correctly under KAT" question, which was
genuinely unconfirmed before, now has a real, source-grounded answer.

---

## 4. Confirmed KAT-Specific Variables

Not wired into `applyInjury` yet (it handles baseline damage/bleeding only, §3) — documented here
because they were confirmed (either via a prior working prototype, cross-checked against real
source, or directly from real KAT function bodies fetched this pass) and are the natural next layer
now that baseline damage is real:

**`kat_surgery_fractures`** — a 6-element array, one entry per body part, indexed identically to
ACE's own `ALL_BODY_PARTS` — **doubly confirmed**: matches the prior working-prototype source, and
directly against KAT's real `addons/surgery/functions/fnc_fractureCheck.sqf` (`ALL_BODY_PARTS find
toLower _bodyPart`). Each entry is a **severity/treatment-stage scale, not a boolean** — confirmed
from the full working prototype's own in-file comment. Real example usage:

```sqf
/*
Fracture severity scale (kat_surgery_fractures per-limb value):
0 = Unaffected, 1 = Stable Fracture, 2 = Compound Fracture, 3 = Comminuted Fracture,
2.1/3.1 = Open Fracture, 2.2/3.2 = Prepared Fracture, 2.5 = Irrigated Fracture, 3.5 = Clamped Fracture

Array index -> limb: [head, torso, leftArm, rightArm, leftLeg, rightLeg]
*/

// Stable fracture, left arm
_unit setVariable ["kat_surgery_fractures", [0, 0, 1, 0, 0, 0], true];

// Compound fracture, right arm
_unit setVariable ["kat_surgery_fractures", [0, 0, 0, 2, 0, 0], true];

// Comminuted fracture, left leg
_unit setVariable ["kat_surgery_fractures", [0, 0, 0, 0, 3, 0], true];

// Open compound fracture, right leg (treatment-progress stage on top of severity 2)
_unit setVariable ["kat_surgery_fractures", [0, 0, 0, 0, 0, 2.1], true];
```

The `.1`/`.2`/`.5` suffixes read as *treatment progress* on top of a base severity (`2`/`3`) rather
than independent severities — e.g. `2` → `2.1` (opened) → `2.2` (prepared) looks like a real
surgical-progression sequence, not confirmed against KAT's own surgery functions beyond
`fractureCheck`'s read-only comparison logic. This array's index order is KAT/ACE's own 6 body
parts — the exact same 6 values AFCM-Simulator's own `LimbId` now uses 1:1
([§4.1](ACE_COMPAT.md#41-limbid--ace3-body-part) on the ACE_COMPAT.md doc), so wiring this in
wouldn't need any folding at all, just a direct index lookup.

- **`kat_breathing_pneumothorax`** / **`kat_breathing_Hemopneumothorax`** /
  **`kat_breathing_Tensionpneumothorax`** — set via `setVariable`, then
  `[_unit] call kat_breathing_fnc_handleBreathing` to actually apply the state (setting the
  variables alone isn't sufficient, confirmed from the prior working prototype).
- **Real item classes** (from KAT's GitHub wiki Classnames page): `kat_bloodIV_A`/`_B`/`_AB`/`_O`
  (+ `_250`/`_500`/`_N` volume variants), `kat_AED`/`kat_X_AED`, `kat_IO_FAST`, `kat_IV_16`,
  pharmacology `kat_ketamine`/`kat_fentanyl`/`kat_atropine`/`kat_amiodarone`/`kat_naloxone`/
  `kat_nitroglycerin`/`kat_TXA`, surgical `kat_clamp`/`kat_plate`/`kat_retractor`/`kat_scalpel`,
  and `kat_stretcherBag`/`Attachable_Helistretcher`.

---

## 5. Known Gaps

- **`removeInjury` is still a stub.** `applyInjury`/`getState` are real now (§3); no real ACE3/KAT
  removal call is wired up yet, same open question as `ace_compat`'s.
- **KAT-specific state (fractures, pneumothorax) not exposed in the UI.** A real implementation
  (`afcm_sim_kat_fnc_applyFracture`/`applyPneumothorax`, called directly rather than through the
  generic `Injury`/backend-interface dispatch) was built and reverted — the injury editor is
  deliberately ACE-only now (DESIGN.md § Selectable Injuries).
- **Fracture-*setting* function unconfirmed.** `fnc_fractureCheck.sqf` (§4) only *reads*
  `kat_surgery_fractures` — the real function that *writes* it (KAT's fracture-infliction entry
  point) hasn't been found yet.
- **Chemical burn trigger path unconfirmed.** `KAT_chemicalBurn` (§3) is a real registered damage
  type, but what actually calls `addDamageToUnit`/`addWound` with that type (a specific ammo type?
  an area-effect script?) hasn't been traced.

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
