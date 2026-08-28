<div align="center">

<img src="../assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../../README.md) · [Design](../DESIGN.md) · [References](../REFERENCES.md) · [Addons Index](README.md) · [Injury Codes](../INJURY_CODES.md) · **ace_compat** · [kat_compat](KAT_COMPAT.md)

</div>

# `afcm_sim_ace_compat`

**A Tasman Dynamics Backend Module** — part of [AFCM-Simulator](../../README.md)'s soft-dependency
backend architecture (see [DESIGN.md §2.5](../DESIGN.md#25-soft-dependencies--runtime-backend-detection)).

Status: **partially implemented** — `applyInjury` is real, `removeInjury` is a stub.
Owner: Tasman Dynamics
PBO: `afcm_sim_ace_compat.pbo` (folder: `addons/ace_compat`)
Function tag: `afcm_sim_ace` (not `afcm_sim_ace_compat` — see [§2 Function Reference](#2-function-reference))

---

## 1. What This Addon Is

`ace_compat` is one of several interchangeable **backend** addons in AFCM-Simulator's soft-dependency
architecture. It implements AFCM-Simulator's backend interface (`applyInjury`/`removeInjury`)
against **vanilla ACE3 medical** (`ace_medical_engine`) — no KAT, no ACM, no AFCM. It exists
specifically so that AFCM-Simulator works for anyone running plain ACE3, without requiring AFCM
(the physiology-engine mod this simulator is *named* after, but does not require) to be installed
at all.

Nothing above `afcm_sim_main`'s backend interface ever calls into `ace_compat`, or ACE3, directly.
`afcm_sim_scenario` and `afcm_sim_spawner` only ever call `afcm_sim_fnc_backend_applyInjury`; which
backend actually handles that call is resolved at runtime, not at authoring time.

### 1.1 Why it's a separate PBO, not an `ifdef`

Each backend — `afcm_compat` (AFCM native), `ace_compat` (this one), `kat_compat`, `acm_compat` —
is its own PBO with its own `requiredAddons` gate, rather than one PBO branching internally on
`isClass (configFile >> "CfgPatches" >> "...")`. A server running ACE3 **and** KAT loads
`ace_compat` *and* `kat_compat` simultaneously; KAT's registration simply outranks ACE's (§1.3), so
KAT wins without `ace_compat` needing to know KAT exists. This is what makes "just ACE3, no KAT"
and "ACE3 + KAT" both work correctly with the same set of installed addons, no user-facing
configuration required.

### 1.2 Requirements

```cpp
requiredAddons[] = {"cba_main", "ace_medical_engine", "afcm_sim_main"};
```

| Dependency | Why |
|---|---|
| `cba_main` | CBA_A3 — hard dependency of the whole mod |
| `ace_medical_engine` | The actual ACE3 component this backend targets. **If this isn't loaded, this entire PBO never loads** — that's the soft-dependency mechanism itself, not a runtime check |
| `afcm_sim_main` | Owns the backend interface (`afcm_sim_fnc_backend_registerBackend`, etc.) this addon registers against. Listed here so HEMTT/the engine guarantee `main` is loaded first |

### 1.3 Registration & Priority

Registers itself on `preInit` (`fnc_preInit.sqf`) at **priority 10** — the lowest of all backends:

| Backend | Priority | Status |
|---|---|---|
| `afcm` (native AFCM) | 20+ (planned) | Deferred stub |
| `kat` | 15 | Confirmed, registers |
| `acm` | between ace/kat (planned) | Deferred stub |
| **`ace`** (this addon) | **10** | **Confirmed, registers** |

Highest priority registered on the machine wins. `ace_compat` sits at the bottom deliberately: it's
the generic fallback for "just plain ACE3," and anything more specific to what's actually installed
(AFCM's own physiology model, KAT's medical overhaul) should take precedence when present. See
[DESIGN.md §2.5](../DESIGN.md#25-soft-dependencies--runtime-backend-detection) for the full
registration/selection lifecycle and why it's safe regardless of PBO load order.

---

## 2. Function Reference

All three functions live under the `afcm_sim_ace` tag (not `afcm_sim_ace_compat` — the `CfgFunctions`
tag in `config.cpp` is shorter than the addon/PBO name), so the real, callable names are:

### `afcm_sim_ace_fnc_preInit`
Registers this backend with `afcm_sim_main`. Runs automatically at `preInit`; never called manually.
Builds an interface `HashMap` (`{"applyInjury": ..., "removeInjury": ...}`) and passes it to
`afcm_sim_fnc_backend_registerBackend` under the id `"ace"`.

### `afcm_sim_ace_fnc_applyInjury`
```sqf
[_unit, _injury] call afcm_sim_ace_fnc_applyInjury
```
**Real implementation.** Never called directly — dispatched to via
`afcm_sim_fnc_backend_applyInjury` when `"ace"` is the active backend. Takes an `Injury` `HashMap`
(see [DESIGN.md §4.2](../DESIGN.md#42-injury-object)) and:

1. Maps the backend-agnostic `limb` (13 real anatomical regions — see
   [§4.1](#41-limbid--ace3-body-part)) to ACE3's 6 lowercase body-part strings, and `woundType`
   (`gunshot`/`shrapnel`/`blast`) to a real ACE3 damage-type class (`bullet`/`grenade`/`shell`).
2. Calls `ace_medical_fnc_addDamageToUnit` with `severity` as the damage amount — this drives ACE's
   normal damage-to-wound pipeline (a *random* wound chosen from that damage type's weighting
   table).
3. If the `Injury`'s `bleeding` flag is `true`, additionally calls `ace_medical_fnc_addWound`
   directly to **deterministically** guarantee a real, sized bleeding wound exists — see
   [§3](#3-why-two-ace-calls-not-one) for why this second call exists.

### `afcm_sim_ace_fnc_removeInjury`
```sqf
[_unit, _injury] call afcm_sim_ace_fnc_removeInjury
```
**Stub.** Logs `"removeInjury stub called for %1 - not yet implemented"` via `diag_log` and returns.
ACE3's real removal-side API (something in the spirit of `ace_medical_fnc_fullHeal`, or a targeted
per-wound removal — unconfirmed which fits the `Injury` object shape) hasn't been researched yet.

### `afcm_sim_ace_fnc_getState`
```sqf
[_unit, _limb] call afcm_sim_ace_fnc_getState
```
**Real implementation.** Backs the injury editor's live medical-status readout
(`afcm_sim_ui`/`RscDisplayAFCM_SIM_InjuryEditor`) via `afcm_sim_fnc_backend_getState`. Read-only and
deliberately only uses ACE3 getters that don't require `local _unit` —
`ace_medical_fnc_isInjured` and `ace_medical_fnc_getOpenWounds` — since, unlike `applyInjury`, this
needs to work when called from any client, not just the server. `ace_medical_fnc_getBloodLoss` is
real and confirmed (REFERENCES.md) but explicitly **not** used here for that reason. Returns a
`HashMap`: `injured` (Bool), `pain` (direct `ace_medical_pain` variable read), `lifeState`/
`incapacitatedState` (vanilla engine commands, not ACE-specific), and `limbWoundCount`/
`limbBleeding` for whichever `LimbId` was passed (folded to an ACE body part the same way
`applyInjury` does — [§4.1](#41-limbid--ace3-body-part)).

### `afcm_sim_ace_fnc_reset`
```sqf
[_unit] call afcm_sim_ace_fnc_reset
```
**Real implementation.** Backs the injury editor's Reset Patient button. Calls the real, confirmed
`ace_medical_fnc_fullHeal` (REFERENCES.md) to wipe all wounds/damage/drugs, then immediately
re-applies `setUnconscious true` — a reset hands back the same "just spawned" unconscious baseline
DESIGN.md §5 establishes for every patient, not a fully awake, healthy unit.

---

## 3. Why Two ACE Calls, Not One

This is the part of `ace_compat` worth understanding rather than just reading — it's the direct
answer to "how do I make a specific injury bleed."

`ace_medical_fnc_addDamageToUnit` is ACE3's normal, high-level way to hurt a unit. Internally it
doesn't create a specific wound — it fires a CBA local event that ACE's own wound-selection logic
picks up, which then rolls a **random** wound from the target damage type's weighting table in
`ACE_Medical_Injuries.hpp`. For `bullet` damage, that table includes `Avulsion`, `Contusion`, and
`VelocityWound` — and `Contusion` doesn't bleed at all. So a "Medium, bleeding: true" injury applied
purely through `addDamageToUnit` could easily land on a non-bleeding bruise, silently breaking the
promise the `Injury` object made.

`ace_medical_fnc_addWound` is a separate, lower-level function that lets you specify the wound
class directly: `[_unit, _bodyPart, [_woundType, _amountOf, _size, _woundDamage]]`. `ace_compat`
uses this — with `_woundDamage` forced to `0` so it doesn't double-count damage already applied by
step 2 above — purely to add a real, guaranteed-bleeding wound entry when the `Injury` says so.

Two real, non-obvious gotchas found by reading ACE3's actual source (`acemod/ACE3` on GitHub — the
wiki documents `addWound`'s existence but not these details):

- `addDamageToUnit` lowercases its `_bodyPart` argument internally before matching it against ACE's
  known body parts, so `"Head"` and `"head"` both work. **`addWound` does not** — it needs the exact
  lowercase strings (`"head"`, `"body"`, `"leftarm"`, `"rightarm"`, `"leftleg"`, `"rightleg"`) or the
  lookup silently fails to match.
- Wound class names for `addWound` are **case-sensitive** and must match a real `CfgWounds` class
  name exactly: `Abrasion`, `Avulsion`, `Contusion`, `Crush`, `Cut`, `Laceration`, `VelocityWound`,
  `PunctureWound`, `ThermalBurn`.

Full source citations for all of this are in [REFERENCES.md](../REFERENCES.md#ace3-medical-source-confirmed-directly-from-acemodace3-not-the-wiki).

---

## 4. Mapping Tables

### 4.1 `LimbId` → ACE3 body part

AFCM-Simulator's `LimbId` has 13 real anatomical values (see
[INJURY_CODES.md §1](../INJURY_CODES.md#1-body-parts--limbid)); ACE3 itself only has 6 real body
parts (lowercase, real `ALL_BODY_PARTS` value), so this backend folds several `LimbId`s onto the
same target:

| AFCM-Simulator `LimbId` | ACE3 body part |
|---|---|
| `head` | `head` |
| `neck` | `body` |
| `chest` | `body` |
| `abdomen` | `body` |
| `pelvis` | `body` |
| `leftUpperArm` | `leftarm` |
| `leftForearm` | `leftarm` |
| `rightUpperArm` | `rightarm` |
| `rightForearm` | `rightarm` |
| `leftThigh` | `leftleg` |
| `leftShin` | `leftleg` |
| `rightThigh` | `rightleg` |
| `rightShin` | `rightleg` |

### 4.2 `woundType` → ACE3 damage type / bleeding wound class

| AFCM-Simulator `woundType` | ACE3 `damageTypes` class (for `addDamageToUnit`) | `addWound` class used when `bleeding: true` |
|---|---|---|
| `gunshot` | `bullet` | `VelocityWound` |
| `shrapnel` | `grenade` | `PunctureWound` |
| `blast` | `shell` | `PunctureWound` |

All six values above are real, confirmed `ACE_Medical_Injuries.hpp` classes — not guessed names.

---

## 5. Known Gaps

- **`removeInjury` is a stub.** No real ACE3 removal call is wired up yet.
- **`bleedRate` is bucketed, not continuous.** ACE's `addWound` only accepts a `_size` enum
  (`0`/`1`/`2`), so the `Injury` object's `bleedRate` (roughly `0.1`–`0.4` from
  `afcm_sim_scenario_fnc_randomizeInjuries`) is bucketed into small/medium/large rather than
  scaled 1:1 — there's no finer-grained lever ACE exposes here.
  [DESIGN.md §4.4](../DESIGN.md#44-injury-levels-randomization-difficulty)'s Easy–F\*CKED! severity
  ranges are a starting proposal, not yet tuned against how "Hard" actually feels in practice on
  this backend specifically.
- **No fracture/airway/breathing handling.** `ace_medical_engine` supports fractures and airway
  state; nothing in `ace_compat` touches either yet, even though DESIGN.md's Extreme/F\*CKED!
  profiles mention "airway/breathing involvement."

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
