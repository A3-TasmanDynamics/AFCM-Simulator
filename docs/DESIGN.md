<div align="center">

<img src="assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../README.md) · **Design** · [References](REFERENCES.md) · [Addons](addons/README.md) · [Injury Codes](INJURY_CODES.md) · [AFCM/Terminology](https://github.com/A3-TasmanDynamics/AFCM/blob/main/docs/TERMINOLOGY.md)

</div>

# AFCM Medical Simulator — Design Doc

Status: **v1.0** — architecture settled, pre-implementation. Nothing in this doc is committed to
code yet; see §9 for the build order.
Owner: Tasman Dynamics
Hard dependency: [CBA_A3](https://github.com/CBATeam/CBA_A3) only.
Soft dependencies (at least one required): [AFCM](https://github.com/A3-TasmanDynamics/AFCM),
or [ACE3](https://github.com/acemod/ACE3) optionally with
[KAT - Advanced Medical](https://steamcommunity.com/workshop/filedetails/?id=2020940806) or
[ACM](https://steamcommunity.com/sharedfiles/filedetails/?id=3235483358).
Terminology: [AFCM/docs/TERMINOLOGY.md](https://github.com/A3-TasmanDynamics/AFCM/blob/main/docs/TERMINOLOGY.md)
— canonical glossary, shared with AFCM. Use it instead of redefining terms here.

AFCM-Simulator is a scenario-authoring and training tool: instructors and mission makers build a
casualty (by limb, injury type, severity, preset, or full randomization) and spawn it into the
world, individually or as a MASCAL batch. It doesn't hard-require any medical mod — it detects
what's actually loaded at mission start and picks a **backend** accordingly (§2.5): AFCM's native
`PatientState` API when AFCM is present, or ACE3 (optionally enhanced by KAT/ACM) when it isn't.
Someone who only wants ACE3 + KAT + AFCM-Simulator, with no AFCM at all, gets a fully working tool
— that's a supported configuration, not a fallback nobody's expected to actually use.

AFCM-Simulator is also **standalone from Tasman-Dynamics-Core** — it does not depend on Core, and
owns its own UI component kit rather than sharing one. See §2.4 and §3 for that reasoning.

---

## 1. Purpose & Scope

AFCM Medical Simulator is a scenario-building tool: instructors/medics configure a patient's
injuries (by limb, by type, by severity), spawn them into the world (individually or via preset,
individually or randomized), and treat them under whichever backend the server has active (§2.5)
— AFCM's physiology engine (Lethal Triad, pharmacology, GCS/airway — its own DESIGN.md §3–§4) when
present, or ACE3/KAT/ACM rules otherwise. It must work identically in singleplayer, hosted MP, and
dedicated server — same constraint set as every other TasDyn framework (see `about.md`:
deterministic, zero-compromise multiplayer sync).

Out of scope for v1: AI-driven patient behavior beyond what AFCM already provides, campaign/
persistence layer, VR training modes.

---

## 2. UI Architecture Decision

### 2.1 The ask
A UI that feels "in-game" — not a browser window, not something that looks bolted on — ideally
approaching what FiveM's NUI gives GTA:V mods (a real HTML/CSS/Vue layer compositing over the
3D view).

### 2.2 Why literal in-viewport HTML isn't on the table
Arma 3's UI system (`RscDisplay`/`RscControls`, `CT_STATIC`, `CT_HTML` for BIKI text only, etc.)
has no control type that hosts a general-purpose web renderer, and there's no public engine hook
to inject an arbitrary rendered surface into the 3D compositing pipeline. Extensions
(`callExtension`/`callExtensionAsync`) can only exchange strings with SQF — they can't hand the
engine a texture or a render target. The one native "dynamic image" mechanism Arma exposes
(`CfgRenderTargets`, used for drone feeds / laptop screens / mirrors) is a live *camera* render,
not a way to inject arbitrary raster/DOM content. Nobody in the Arma community has shipped a true
DOM-in-viewport mod for this reason — it would require Bohemia engine source access.

### 2.3 The option that gets closest: a transparent overlay window
What Discord's in-game overlay, MSI Afterburner/RTSS, and Nvidia's overlay all do is **not**
inject into the game's render pipeline — they run a separate, borderless, always-on-top,
click-through-toggleable window sized and positioned to exactly match the game window, updated
every frame the game window moves/resizes/gains focus. Visually, to the player, it reads as
"in-game." Overwolf is a commercial platform built specifically to productize this pattern for
games with no native overlay API (which is our exact situation).

This is a real, buildable option — but it's a genuine second application, not a script:
- **Process model**: a companion process (Rust/C++ + a lightweight web renderer, e.g. CEF
  offscreen rendering or a webview crate) that Arma talks to via `callExtension`/named pipe/local
  WebSocket. The companion window is *not* the Arma process — no DLL injection into `arma3.exe`.
  That distinction matters: injecting into the game process is a BattlEye-flag risk on
  BattlEye-enabled servers; a sibling window that just reads the Arma window's position/size via
  Win32 (`GetWindowRect`, `SetWindowPos`, `WS_EX_LAYERED`/`WS_EX_TRANSPARENT`) is not.
- **Hard problems that make this a real project, not a weekend spike**: click-through toggling
  (must swap `WS_EX_TRANSPARENT` on/off cleanly when a menu opens/closes so mouse events go to
  the right target), keeping pace with borderless/exclusive-fullscreen mode and multi-monitor/DPI
  scaling, window-move/alt-tab/minimize edge cases, and the IPC bridge design (what SQF pushes to
  the overlay — unit/injury state — vs. what the overlay pushes back — treatment actions).
- **Player friction**: unlike a pure SQF mod, this requires a local companion executable running
  alongside Arma. That's a real install/trust ask for a Steam Workshop mod, and dedicated servers
  can't force it — it would have to be fully optional, with the native-dialog UI as the
  always-available fallback for anyone who doesn't run the companion app.

### 2.4 Decision
- **v1 ships with native SQF dialogs** (`RscDisplay`/`RscControls`), built as a reusable
  component set owned entirely inside AFCM-Simulator (`addons/afcm_ui`, see §3) so it doesn't have
  to be redone in a modern visual style per-screen. This is guaranteed to work for every player, in
  SP/MP/dedicated, with zero install friction, and it's exactly how ACE3's own interaction menu and
  KAT's UI already work — so it composes cleanly with both.
- **AFCM is standalone**: it does not depend on Tasman-Dynamics-Core. The dialog/component kit
  lives inside `afcm_ui` and is not shared infrastructure — no second Workshop subscription, no
  Core/AFCM version-compat surface to manage. The tradeoff (documented for the record): if a future
  TasDyn mod also needs a native-dialog UI kit, it either forks this one or a shared kit gets
  extracted later once there's a second real consumer — not speculatively now.
- **The overlay-window approach is not discarded** — it's logged as a **Phase-2 research spike**,
  scoped and time-boxed on its own, evaluated for real before any AFCM screen depends on it. AFCM's
  data model and SQF↔UI event contract (§5–§6) should be designed so a future overlay frontend can
  be swapped in as a second renderer without touching the underlying injury/patient logic — i.e.,
  keep "what the UI can do" (a small, serializable command/event set) decoupled from "how it's
  drawn." If this spike is ever pursued, it can still live in AFCM-Simulator directly; nothing here
  requires Core.

### 2.5 Soft Dependencies & Runtime Backend Detection

**The mechanism.** In Arma/HEMTT, `requiredAddons[]` in a PBO's `CfgPatches` is a hard, load-time
requirement — if it's missing, that PBO refuses to load. But that requirement is per-*PBO*, not
per-*mod*: a mod is just a folder of independently-loaded PBOs. This is exactly how CBA_A3 and
ACE3 ship optional third-party compatibility without hard-requiring those mods for everyone —
their compatibility PBOs `requiredAddon` the target mod, so on a setup without it, only that one
PBO silently fails to load (logged, not fatal) while the rest of the mod works fine.

AFCM-Simulator uses the same pattern instead of a single `afcm_sim_compat` addon gated by internal
logic:

- **`afcm_sim_main`** — `requiredAddons = {"cba_main"}` only. Owns the **backend interface itself**
  (a fixed set of function names, e.g. `afcm_sim_fnc_backend_applyInjury`) and the registration/
  selection machinery (§6). No mention of AFCM, ACE3, KAT, or ACM anywhere in its config — it
  doesn't know or care which backend ends up active, only how candidates register and how one gets
  picked.
- **`afcm_sim_ui`** — `requiredAddons = {"cba_main"}` only (doesn't touch the backend interface
  directly; dialogs publish onto the UI event bus instead, §3). **`afcm_sim_scenario` /
  `afcm_sim_spawner`** — `requiredAddons` includes `afcm_sim_main` (to call the backend interface)
  and, for spawner, `afcm_sim_scenario` too. None of the three mention AFCM, ACE3, KAT, or ACM —
  they call `afcm_sim_fnc_backend_*` and have no idea which backend is actually active.
- **`afcm_sim_afcm_compat`** — `requiredAddons = {"cba_main", "afcm_main", "afcm_sim_main"}`. Only
  loads if AFCM is present. Will implement the backend interface against AFCM's `PatientState` API
  and register itself as an available backend on `preInit` once AFCM's API is stable — deferred,
  config-only stub for now (§9).
- **`afcm_sim_ace_compat`** — `requiredAddons = {"cba_main", "ace_medical_engine", "afcm_sim_main"}`.
  Only loads if ACE3 is present. Implements the backend interface against vanilla
  `ace_medical_engine` hitpoints. Registers at priority 10.
- **`afcm_sim_kat_compat`** / **`afcm_sim_acm_compat`** — each its own PBO rather than internal
  detection inside `ace_compat`, so a server running ACE3+KAT loads `ace_compat` *and* `kat_compat`
  (the latter outranks the former, since KAT's model should take precedence when it's actually
  present). **`kat_compat` is confirmed and registers as a real backend** (priority 15) —
  `requiredAddons` gates on the real `kat_main` (KAT's actual `CfgPatches` root, confirmed via
  [github.com/KAT-Advanced-Medical/KAM](https://github.com/KAT-Advanced-Medical/KAM), see
  REFERENCES.md); `applyInjury`/`getState` are now real too (KAT extends ACE3's own wound pipeline
  rather than replacing it — confirmed from KAT's real source, KAT_COMPAT.md §3 — so
  `ace_compat`'s exact ACE3 calls apply correctly here as well). `removeInjury` is still a stub.
  **`acm_compat` remains a deferred, config-only stub** —
  `requiredAddons` is still identical to `ace_compat`'s (ACE3 only) because ACM's real `CfgPatches`
  class name isn't confirmed (§8) — registering it as a real backend before that would make it win
  priority over `ace_compat` on any ACE3-only setup, which would be wrong. KAT and ACM are both
  alternative overhauls of ACE3 medical and aren't expected to run together in practice; if both
  were somehow present and both fully implemented, priority selection between them is still an
  open question.
- **Registration happens on `preInit`, selection happens on `postInit`** — both are native
  `CfgFunctions` phases (`preInit = 1;` / `postInit = 1;`), not a CBA event. The engine guarantees
  every addon's `preInit` finishes, across the whole config, before any addon's `postInit` starts —
  that ordering guarantee is what makes registration-then-selection safe regardless of which
  compat addons happen to be present or their load order relative to each other. (An earlier
  attempt tried subscribing to a `"CBA_addons_postInit"` event via `CBA_fnc_addEventHandler` —
  confirmed via an actual in-game launch that this event doesn't exist as a subscribable global
  broadcast; CBA's own postInit is the same per-addon `postInit=1` mechanism, not something else to
  hook into.) Highest-priority registered backend wins: `afcm_compat` (once implemented, priority
  20+) outranks `kat_compat` (priority 15, confirmed working) outranks `acm_compat` (once
  implemented) / `ace_compat` (priority 10). If nothing registers at all —
  no medical mod is present — `afcm_sim_scenario`'s injury-application actions disable themselves
  with a clear "no medical backend detected" message rather than silently no-op-ing or erroring.
- **MP consistency**: backend selection happens server-side (or the logical host) and is
  broadcast via `publicVariable` at mission init (§6), so every client agrees on which backend is
  active even if individual clients' local mod lists differ slightly — avoids a client whose
  loadout lacks AFCM seeing UI for drugs/procedures the active backend doesn't actually support.

This means "just want ACE3 + KAT + AFCM-Simulator" is a first-class supported configuration, not
an afterthought bolted onto an AFCM-first design — and the reverse (AFCM + AFCM-Simulator, no
ACE3 at all) works identically, since neither backend addon is required for the other to function.

---

## 3. System Layering

```
AFCM-Simulator (standalone addon, no Tasman-Dynamics-Core dependency)
   ├─ requires          ─→ CBA_A3 (only hard dependency)
   ├─ soft, either/both ─→ AFCM   (activates afcm_compat)
   ├─ soft, either/both ─→ ACE3   (activates ace_compat)
   ├─ soft, either/both ─→ KAT    (activates kat_compat — confirmed working, §2.5)
   └─ soft, either/both ─→ ACM    (activates acm_compat, once real detection lands — §2.5)
```

Everything this tool needs beyond a chosen backend — the backend interface, dialog framework,
event bus, scenario/domain logic — lives inside AFCM-Simulator's own addons (§7), backend-agnostic
by construction (§2.5). The internal split:

- **`afcm_sim_main`** owns the **backend interface + detection mechanism itself**
  (`afcm_sim_fnc_backend_registerBackend`/`selectBackend`/`applyInjury`/`removeInjury`/`getActive`,
  §2.5/§6) — foundational infra every other addon sits on top of, not scenario-specific domain
  logic, which is why it lives here rather than in `afcm_sim_scenario`. Every other addon in this
  repo `requiredAddon`s `afcm_sim_main`.
- **`afcm_sim_ui`** owns the **dialog framework** (native-dialog component kit: buttons, sliders,
  limb-diagram hit-areas, dropdowns, list boxes — styled once, reused across every screen) and the
  **event bus** used to decouple "UI raised an intent" from "domain logic executed it," so a
  Phase-2 overlay could later publish/subscribe to the same bus without a rewrite.
- **`afcm_sim_scenario` / `afcm_sim_spawner`** own: injury presets, randomization profiles, patient
  spawner, stretcher placement, the map tool — and call the **backend interface** (owned by
  `afcm_sim_main`), never AFCM or ACE3 directly.
- **`afcm_sim_afcm_compat`** / **`afcm_sim_ace_compat`** / **`afcm_sim_kat_compat`** /
  **`afcm_sim_acm_compat`** (§2.5) — the interchangeable backend implementations, one per target
  medical system. Each is isolated precisely so any one can be deleted without touching anything
  else. All `requiredAddon` `afcm_sim_main` (for the interface they register against), not
  `afcm_sim_scenario`.
- **`afcm_sim_zeus`** / **`afcm_sim_eden`** own the editor-facing side of patient
  authoring/placement (§5) — a Zeus module ("Spawn Patient") and two Eden modules ("AFCM Patient"
  and "AFCM MASCAL Zone"). **Implemented** — all three call real `afcm_sim_spawner` functions, not
  stubs. Only MASCAL Zone still has an injury-level attribute/randomizes — Spawn Patient and AFCM
  Patient spawn clean and rely on the "Edit Injuries" selection flow instead. `requiredAddon`
  `afcm_sim_main`, `afcm_sim_scenario`, and `afcm_sim_spawner`.

---

## 4. Data Model

### 4.1 Body limb selection
The `LimbId` set below is the backend-agnostic vocabulary the UI/scenario layer actually uses — a
direct 1:1 match to ACE3's own 6 real body parts, deliberately (a finer 13-region anatomical
breakdown was built and then reverted in favour of keeping this simple and matching ACE exactly).
Each active backend (§2.5) maps it to its own target internally — the scenario layer never sees an
AFCM site or an ACE3 body part directly, only a `LimbId`:

| AFCM-Simulator `LimbId` | Real-world region | `afcm_sim_afcm_compat` target | `afcm_sim_ace_compat` target (ACE3 body part) |
|---|---|---|---|
| `head` | Head | AFCM head site | `head` |
| `chest` | Chest/torso | AFCM torso site | `body` |
| `leftArm` / `rightArm` | Left/right arm | AFCM left/right arm site | `leftarm` / `rightarm` |
| `leftLeg` / `rightLeg` | Left/right leg | AFCM left/right leg site | `leftleg` / `rightleg` |

Confirmed in [ACE_COMPAT.md §4.1](addons/ACE_COMPAT.md#41-limbid--ace3-body-part) that these are
ACE3's actual real body-part strings, not guessed. `tourniquetable` (§4.2) is only ever `true` for
`leftArm`/`rightArm`/`leftLeg`/`rightLeg` — never `head`/`chest`.

### 4.2 Injury object
This is scenario-authoring input — what a preset or randomizer produces — passed to whichever
backend is active (§2.5) via the backend interface:
```
Injury = {
    limb: LimbId,             // backend-agnostic, see §4.1
    woundType: String,        // backend-agnostic classification; each backend maps this to its
                               // own vocabulary (AFCM trauma/bleed class, or ACE3 CfgWoundTypes /
                               // KAT wound classes) — the scenario layer doesn't know which
    severity: 0.0..1.0,       // initial trauma magnitude at time of application
    bleeding: Bool,
    bleedRate: Number,        // seed value only — whichever backend is active then derives the
                               // *actual* ongoing rate from its own model; this is not the
                               // authoritative rate once the backend starts simulating
    tourniquetable: Bool,     // derived from limb, not authored per-injury
    variables: {}             // free-form key/value for custom presets (e.g. "fracture": true)
}
```

### 4.3 Injury preset
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
Presets ship in two tiers: **built-in** (authored by TasDyn, packed in the addon — gunshot wound,
HE frag pattern, blast-lung, etc.) and **user-saved** (written to the mission/profile namespace so
mission makers and players can build and re-share their own — this is the "custom ones people have
made and saved" requirement). User presets need an export/import format (plain-text/JSON-in-SQF-
readable-string) so they're shareable outside the mission file.

### 4.4 Injury levels (randomization difficulty)
A named difficulty maps to a randomization *profile*, not a fixed injury set:

| Level | Injury count | Severity range | Bleed probability | Notes |
|---|---|---|---|---|
| Easy | 1 | 0.1–0.3 | Low | Single limb, non-life-threatening |
| Medium | 1–2 | 0.2–0.5 | Medium | May include one bleed |
| Hard | 2–3 | 0.4–0.7 | High | Multiple limbs, likely bleed |
| Extreme | 3–4 | 0.6–0.9 | High | Compound injuries, airway/breathing involvement |
| F*CKED! | 4+ | 0.8–1.0 | Near-certain, multi-site | Full MASCAL-style casualty, time-pressure case |

These ranges are a starting proposal, not tuned values — needs a tuning pass **per active
backend**: against AFCM's physiology thresholds (coagulopathy/blood-volume curves, per AFCM
DESIGN.md §2.1/§3) for `afcm_sim_afcm_compat` so "Hard" reliably feels harder inside the Lethal
Triad engine, and separately against KAT's/ACM's severity/treatment thresholds for
`afcm_sim_ace_compat` — the same "Hard" label should feel comparably hard on either backend, even
though the underlying math is completely different per backend.

> **Naming note** (TERMINOLOGY.md §2/§9): these five names are a gameplay-authoring difficulty
> scale, not the real T1–T4 military triage categories. Keep them visually/verbally distinct in UI
> copy — a scenario labelled "Hard" should never appear next to, or be confusable with, a patient
> labelled "T2." If a MASCAL sorting/triage exercise feature is ever built, it should use T1–T4
> directly rather than repurposing these labels.

---

## 5. Feature Breakdown

Status markers below reflect actual implementation, not just design intent — most of this section
is still the plan, not the state of the repo.

- **Selectable Body Limbs** — limb-diagram UI (native dialog, clickable silhouette regions) →
  emits `limb.selected` event on the bus. **Implemented** (§2 button-per-limb version, not a
  silhouette): picking a limb publishes `limb.selected` and opens the injury editor below for the
  same limb — `limb.selected` is consumed now, not a dead-end event.
- **Selectable Injuries** — per-limb injury editor (wound type, severity, bleed toggle, custom
  variables) → emits `injury.applied`/`injury.removed`. **Implemented, partially**: wound
  type/severity/bleeding are real (`RscDisplayAFCM_SIM_InjuryEditor`, `afcm_sim_ui`); severity is a
  4-band combo (Light/Moderate/Severe/Critical → 0.25/0.5/0.75/1.0), not a continuous slider.
  `variables` (custom free-form fields) not exposed in the UI. Publishes `injury.applied`; no
  removal path yet, so no `injury.removed`. Entry point is a vanilla `addAction` ("Edit Injuries")
  added to every spawned patient — not an ACE interaction-menu entry (REFERENCES.md documents that
  API as confirmed-but-unused, consistent with §2.4's decision to keep AFCM-Simulator's own UI
  ACE-independent). Apply routes through `afcm_sim_scenario_fnc_serverApplyInjury` → the same
  `afcm_sim_fnc_backend_applyInjury` dispatch the randomizer uses (DESIGN.md §6 — server-authoritative,
  never applied client-side). Also shows **live medical state** while open — a new
  `afcm_sim_fnc_backend_getState` dispatch (mirrors `applyInjury`'s pattern, read-only, safe from
  any machine) reports consciousness (`lifeState`/`incapacitatedState`), pain, whether the unit is
  injured at all, and the selected limb's open-wound/bleeding state; `afcm_sim_ace_compat` implements
  it via `ace_medical_fnc_isInjured`/`getOpenWounds` (both safe to call off the unit's owning
  machine, unlike `getBloodLoss` which requires `local _unit` and is deliberately not used here).
  Refreshed on a 0.5s `CBA_fnc_addPerFrameHandler` while the dialog is open, removed on close. A
  **Reset Patient** button wipes everything done to the patient so far (wounds, bandages, drugs)
  via a new `afcm_sim_fnc_backend_reset` dispatch — `afcm_sim_ace_compat`/`afcm_sim_kat_compat` both
  implement it as `ace_medical_fnc_fullHeal` (real, confirmed) followed by re-locking the unit back
  to `setUnconscious true`, so a reset hands back the same "just spawned" baseline rather than a
  fully awake, healthy unit. Routes through `afcm_sim_scenario_fnc_serverReset`, same
  server-authoritative request pattern as Apply. Unlike Apply/Cancel, Reset leaves the dialog open —
  the live status readout shows the clean state within moments and the instructor can immediately
  pick a fresh injury. Deliberately **ACE-only selections** — wound type/severity/bleeding, nothing
  backend-specific beyond that, since ACE and KAT both consume the exact same real calls identically
  underneath (ACE_COMPAT.md §3/KAT_COMPAT.md §3). The only backend-awareness is a check against
  `afcm_sim_fnc_backend_getActive`: if nothing usable is active (nothing registered, or only `afcm`
  — not yet supported by this UI, DESIGN.md §2.5), Apply is disabled and the limb label explains why
  instead of offering controls that would silently no-op. A fuller version of this — real,
  backend-conditional KAT-only **Fracture**/**Pneumothorax** controls
  (`kat_surgery_fractures`/`kat_breathing_*`, INJURY_CODES.md §6) shown only when KAT is active —
  was built and then reverted in favour of this simpler version; the real KAT-only functions it
  would have used are still documented if revisited.
- **Injury Presets** — built-in + user library, save/load/export/import, apply-to-selected-unit.
  *Not implemented.*
- **Injury Levels (Randomization)** — pick a level → domain logic rolls a concrete injury set from
  that level's profile → applies via the same `injury.applied` path presets use (one application
  pipeline, three sources: manual, preset, randomized). **Implemented**:
  `afcm_sim_scenario_fnc_randomizeInjuries` rolls a real Injury array per the §4.4 profile table.
  The "one pipeline, three sources" framing is aspirational until manual/preset paths exist — right
  now randomization is the only source feeding the backend.
- **Spawn Patient (Zeus)** — spawns a clean, unconscious patient at the module's position; the Zeus
  operator then picks the actual injury via the "Edit Injuries" scroll action every spawned patient
  gets (§ Selectable Injuries above), rather than a random roll. **Implemented**:
  `afcm_sim_spawner_fnc_spawnPatient` called directly (no injuries argument), `disableAI "ALL"` set
  on the unit so it can't do anything autonomously. Two targeted upstream fixes for patients
  "healing themselves" (`afcm_sim_fnc_disableSpontaneousWakeup`, `main`/`preInit`; `disableAI`
  above) are both real and grounded in ACE3 source but didn't fully hold up in live testing — see
  REFERENCES.md for the full investigation. `spawnPatient` now also runs a recurring safeguard
  directly on the symptom: every 3s, for as long as the specific unit exists, it forces
  `setUnconscious true` again, regardless of which upstream system caused it to wake. This means a
  patient won't wake up even from fully successful real treatment until an instructor explicitly
  resets it (`afcm_sim_fnc_backend_reset`) — accepted as the right trade-off for a training tool
  where "spontaneously recovers on its own" was never the intended behaviour either way. No
  randomized identity/loadout yet — spawns a
  plain `C_man_1` civilian. **Not** randomized anymore despite the module class still being named
  `AFCM_SIM_ModuleSpawnRandomPatient` internally (display name is now just "Spawn Patient" —
  renaming the class would orphan it in any mission that's already placed one).
  `afcm_sim_spawner_fnc_spawnRandomPatient` (the actual randomizer wrapper) still exists and is
  still used by AFCM MASCAL Zone (§ below) — batch/mass-casualty drills are the one place
  random-by-design still makes sense.
- **AFCM Patient (Eden)** — design-time patient placement for scripted scenarios: a mission maker
  places the module, and it spawns a clean, unconscious patient on mission start
  (`afcm_sim_eden`) — same "Edit Injuries" selection flow as Zeus's Spawn Patient, not a random
  roll. Distinct from Spawn Patient (Zeus, live) and Map to Spawn Patients (below, in-mission) —
  this is the pre-authoring path. **Implemented**: calls `spawnPatient` directly, no injuries
  argument. The module's old "Injury Level" attribute is gone (eden/config.cpp) — it stopped doing
  anything once this module stopped auto-randomizing.
- **Stretcher Placement** — selectable stretcher type (class list sourced from whichever backend
  is active, §2.5), ghost-preview placement (surface-snapped, like Zeus placement), spawns synced
  for MP. *Not implemented.*
- **Map to Spawn Patients** — map-click patient placement/preview, supports batch placement for
  MASCAL scenarios, respects the same spawn pipeline as Spawn Patient. *In-mission map-click tool
  not implemented; the Eden-editor design-time equivalent is* **AFCM MASCAL Zone** *(§7 —
  `AFCM_SIM_ModuleMascalZone`), which **is** implemented: patient-count + injury-level attributes,
  spawns that many patients (loosely scattered via `spawnPatient`'s own position jitter) on mission
  start.*
- **Clear spawned patients** — not in the original feature list; added after reviewing a prior
  working prototype (REFERENCES.md) that needed exactly this. **Implemented**, simplified:
  `afcm_sim_spawner_fnc_clearAllPatients` deletes every patient spawned via `spawnPatient` and
  clears the tracking list. No per-spawner/session-scoped clearing yet (the prototype's pattern —
  clear only what one specific Zeus placement spawned — isn't built; this is a global "clear all"
  only). No UI/module trigger for it yet either — callable, not yet exposed.
  **The prototype's actual technique**, confirmed from its full source (`med_sim.sqf`, REFERENCES.md):
  a `HashMap` keyed by a composite session id string — `"{spawnerNetId}|L{level}|C{count}|{timestamp}"`
  — built fresh per spawn call, with a clear function that filters keys by matching `spawnerNetId`
  prefix, then either clears just the most-recent-timestamp match ("last") or every match ("all")
  for that specific spawner. Worth reusing directly if per-spawner clearing gets built here —
  `netId` of the placed Zeus/Eden module logic is the natural `spawnerNetId` equivalent.

---

## 6. Multiplayer Architecture

Following the same principles as the rest of the TasDyn stack (`about.md` — deterministic, no
desync, validation on an authority machine):

- **Backend selection**: the server (or logical host) determines the active backend at mission
  `postInit` per the priority in §2.5 and `publicVariable`s the result before any scenario UI
  becomes interactive. Clients never decide their own backend locally — a client whose personal
  mod list happens to include AFCM must still defer to the server's choice (e.g. ACE3-only,
  because the server doesn't run AFCM), otherwise that client's UI would offer treatments the
  server-authoritative state can't actually apply.
- **Authority**: patient spawning, injury application, and preset resolution execute
  **server-side** (or the logical host in a non-dedicated game) as the single source of truth.
  Clients send *requests* (spawn patient X with preset Y / apply injury Z to unit U); the server
  validates and executes against the active backend, then the resulting state propagates through
  that backend's own existing sync — AFCM's server-authoritative `PatientState` replication (AFCM
  DESIGN.md §4) on the native path, or ACE3/KAT's existing hitpoint/medical sync in compat mode.
  AFCM-Simulator does not need to invent its own state-sync layer either way, only the
  request→authority→domain-call path for *scenario-specific* actions (preset application, spawn
  placement, randomization) that neither backend knows about on its own.
- **JIP**: preset library (built-in) is static per-addon-version, so no JIP concern. User-saved
  presets and any in-progress MASCAL spawn batches need to be re-sendable to late-joiners — likely
  via a `publicVariable`d small state table on the server, or a JIP event handler, scoped small
  since it's just metadata (preset defs), not per-frame state.
- **Validation**: since this is a training/scenario tool (trusted-user context, typically run by
  instructors/zeus), request validation can be lighter than a PvP-integrity system — but should
  still reject malformed requests (unknown preset id, out-of-range severity) rather than trust
  client input blindly, consistent with "Deterministic" / "no desync" as a principle even without
  an adversarial threat model.

---

## 7. Repo / Module Layout

```
AFCM-Simulator/
  addons/
    main/          # afcm_sim_main — backend interface + detection mechanism (§2.5/§6)
                    # requiredAddons = {cba_main} — everything else requiredAddons this
    ui/            # afcm_sim_ui — native dialogs + component kit + event bus, self-contained
                    # requiredAddons = {cba_main}
    scenario/      # afcm_sim_scenario — injury model, preset library, randomization profiles
                    # requiredAddons = {cba_main, afcm_sim_main} — calls the backend interface only
    spawner/       # afcm_sim_spawner — patient spawner, stretcher placement, map tool
                    # requiredAddons = {cba_main, afcm_sim_main, afcm_sim_scenario}
    zeus/          # afcm_sim_zeus — "Spawn Patient" Zeus module (§5), implemented
                    # requiredAddons = {cba_main, afcm_sim_main, afcm_sim_scenario, afcm_sim_spawner}
    eden/          # afcm_sim_eden — "AFCM Patient"/"AFCM MASCAL Zone" Eden modules (§5), implemented
                    # requiredAddons = {cba_main, afcm_sim_main, afcm_sim_scenario, afcm_sim_spawner}
    afcm_compat/   # afcm_sim_afcm_compat — implements the interface against AFCM's PatientState API
                    # requiredAddons = {cba_main, afcm_main, afcm_sim_main} — only loads if AFCM present
                    # deferred, config-only (§9)
    ace_compat/    # afcm_sim_ace_compat — implements the interface against vanilla ace_medical_engine
                    # requiredAddons = {cba_main, ace_medical_engine, afcm_sim_main} — only loads if ACE3 present
    kat_compat/    # afcm_sim_kat_compat — KAT-specific compat backend, own PBO (not internal ace_compat
                    # detection) so ace_compat+kat_compat can load side by side and kat_compat outranks it
                    # requiredAddons = {cba_main, ace_medical_engine, kat_main, afcm_sim_main} — real
                    # target confirmed (REFERENCES.md); registers as a real backend, priority 15
    acm_compat/    # afcm_sim_acm_compat — same treatment as kat_compat, for ACM, but still deferred:
                    # requiredAddons currently = ace_compat's (ACE3 only) — ACM's real CfgPatches class
                    # name isn't confirmed yet (§8); config-only, doesn't register as a backend yet
  docs/
    DESIGN.md      # this file
    PRESET_FORMAT.md   # (future) user preset export/import spec
```

Folder names on disk are bare (`ui`, `scenario`, ...) per standard HEMTT/ACE3-style convention —
HEMTT prepends the project prefix (`afcm_sim`) automatically to produce each PBO. The full
`afcm_sim_*` name is still each addon's `CfgPatches` class name and the name used everywhere else
in this doc (`requiredAddons`, prose) — only the physical folder differs from that name.

No changes required to Tasman-Dynamics-Core for this project. None of the four compat addons
require each other — see §2.5 for why that split makes AFCM (and ACE3/KAT/ACM) genuinely optional
rather than one hard-required with the others bolted on.

---

## 8. Open Questions (need your call before implementation starts)

1. **KAT internals — partially resolved.** Real repo/docs found (REFERENCES.md):
   [github.com/KAT-Advanced-Medical/KAM](https://github.com/KAT-Advanced-Medical/KAM) +
   [GitBook docs](https://kam-1.gitbook.io/kam-docs). `CfgPatches` root (`kat_main`) and real item
   class names are confirmed — `afcm_sim_kat_compat`'s `requiredAddons` is fixed and it registers
   as a real backend. **Still open**: the actual wound/injury-application function (KAT's
   equivalent of `ace_medical_fnc_addDamageToUnit`) — the wiki's Injuries/Settings pages exist but
   returned placeholder or thin content when checked; needs either a proper source-checkout or a
   more targeted look at the wiki/GitBook pages. ACM's real `CfgPatches` class name is still fully
   unconfirmed — no equivalent source has been found for `afcm_sim_acm_compat` yet.
2. **AFCM API surface** — this doc assumes AFCM will expose a stable `PatientState`-mutation API
   (per AFCM DESIGN.md §6); needs to be nailed down jointly with AFCM's own implementation order
   (its §9 roadmap) before `afcm_sim_afcm_compat` can be built — though per §9 below, this no
   longer blocks AFCM-Simulator's *first* shippable version.
3. **Preset sharing format** — plain SQF-readable string blob (easy in-mission use, ugly to diff/
   share) vs. JSON file players place in a folder (needs a file-read approach compatible with
   dedicated servers)?
4. **MASCAL batch spawning scale** — what's the realistic max simultaneous patients (drives how
   much we need to worry about spawn-request throttling/authority queueing)?
5. **Phase-2 overlay spike** — worth timeboxing now as a small proof-of-concept (e.g. just get a
   transparent click-through window tracking the Arma window with one live-updating field from
   SQF), or defer until the native-dialog UI is feature-complete?
6. **Backend interface surface** — §2.5 assumes a fixed function-name interface
   (`afcm_sim_fnc_backend_applyInjury` and siblings) is enough to cover both backends' actual
   capabilities without leaking backend-specific concepts back into `afcm_sim_scenario`. Needs a
   full function list drafted before either backend addon is implemented, ideally validated
   against *both* backends' real APIs at once so the interface isn't accidentally shaped around
   whichever one gets designed first.
7. **No-backend UX** — confirm the exact behaviour when neither AFCM nor ACE3 is present: disable
   injury-application actions with a message (current assumption, §2.5), or refuse to let the mod
   initialize at all? Affects whether `afcm_sim_ui`/`afcm_sim_scenario` need a "no backend" state
   in their dialogs, not just a binary on/off.
8. **Zeus/Eden module trigger mechanics — resolved (with a real fix along the way).** Confirmed via
   an actual in-Zeus test: the `function=`/`functionPriority=`/`isTriggerActivated=0`/`isGlobal=1`
   pattern is correct and fires as expected. But the module didn't *appear in the Zeus curator
   browser at all* until `scopeCurator = 2;` was added — Zeus has its own visibility gate,
   independent of the `scope = 2;` that's sufficient for Eden. Fixed on all three module classes
   (`AFCM_SIM_ModuleSpawnRandomPatient`, `AFCM_SIM_ModulePatientPlacement`,
   `AFCM_SIM_ModuleMascalZone`); Eden visibility itself is still not independently re-confirmed
   after the fix, only Zeus.

---

## 9. Phased Roadmap

- **v0.1 (this doc)** — design only.
- **v1 MVP** — native-dialog UI, the backend interface (§2.5) and its detection/selection logic,
  manual limb + injury selection, single-patient spawn (no map tool yet), SP + MP validated —
  shipped against **`afcm_sim_ace_compat` first**. ACE3 and KAT already exist today; AFCM does
  not yet (its own §9 shows physiology core landing in AFCM's v1, cardiac/defib in v2). Building
  the ACE backend first means AFCM-Simulator has a real, usable v1 without waiting on AFCM's build
  order at all — and proves the backend-interface abstraction (§2.5 open question #6) against a
  concrete, already-shipped mod before `afcm_sim_afcm_compat` has to conform to it.
- **v1.x** — `afcm_sim_afcm_compat` lands once AFCM's `PatientState` API (§8 open question #2) is
  stable enough to build against — likely tracking AFCM's own v1/v2, not gated on AFCM-Simulator's
  own version number. `afcm_sim_kat_compat`'s scaffolding has already landed (registers as a real
  backend, priority 15) — its actual wound-application call is the remaining piece, tracked
  alongside `afcm_sim_ace_compat`'s. `afcm_sim_acm_compat` lands once its real `requiredAddons`
  target is confirmed (§8 #1).
- **v2** — injury presets (built-in + user save/load); randomization levels; Random Patient (incl.
  making the `afcm_sim_zeus` module real); stretcher placement — implemented once against the
  backend interface, so every active backend gets them simultaneously rather than one at a time.
- **v3** — map spawn tool, MASCAL batch placement, preset import/export/sharing, making the
  `afcm_sim_eden` module real.
- **Phase-2 spike (parallel, inside AFCM-Simulator)** — overlay-window proof of concept, evaluated
  independently; only promoted to "supported" if the hard problems in §2.3 are actually solved.

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
