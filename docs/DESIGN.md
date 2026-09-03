<div align="center">

<img src="assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../README.md) · **Design** · [References](REFERENCES.md) · [Addons](addons/README.md) · [Injury Codes](INJURY_CODES.md) · [Changelog](changelogs/README.md) · [AFCM/Terminology](https://github.com/A3-TasmanDynamics/AFCM/blob/main/docs/TERMINOLOGY.md)

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
- **A native `afcm_sim_afcm_compat` backend isn't being built at this stage** — there's no AFCM to
  target yet, and the empty config-only stub this repo carried earlier was removed rather than left
  as scaffolding nothing pointed at (§9). The soft-dependency mechanism below already covers this
  case cleanly if that changes later: a new PBO gated on `afcm_main`, registering above `kat_compat`
  on `preInit`, same shape as every backend below.
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
  hook into.) Highest-priority registered backend wins: today that's `kat_compat` (priority 15,
  confirmed working) over `acm_compat` (once implemented) / `ace_compat` (priority 10) — a future
  native `afcm_compat`, if one's ever built, would register above all three (20+). If nothing
  registers at all —
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
   ├─ soft, either/both ─→ ACE3   (activates ace_compat)
   ├─ soft, either/both ─→ KAT    (activates kat_compat — confirmed working, §2.5)
   └─ soft, either/both ─→ ACM    (activates acm_compat, once real detection lands — §2.5)

AFCM itself has no compat backend at this stage (§2.5) — the mod this simulator is a companion to
doesn't exist yet to target. The soft-dependency mechanism above already covers adding one later.
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
- **`afcm_sim_ace_compat`** / **`afcm_sim_kat_compat`** / **`afcm_sim_acm_compat`** (§2.5) — the
  interchangeable backend implementations, one per target medical system. Each is isolated
  precisely so any one can be deleted without touching anything else (as `afcm_sim_afcm_compat`
  itself was — no native AFCM to target at this stage, §9). All `requiredAddon` `afcm_sim_main`
  (for the interface they register against), not `afcm_sim_scenario`.
- **`afcm_sim_zeus`** / **`afcm_sim_eden`** own the editor-facing side of patient
  authoring/placement (§5) — Zeus's "Spawn Patient"/"MCI Spawner"/"Edit Injuries" and Eden's own
  "AFCM Patient"/"Interactive Terminal". **Implemented** — all call real `afcm_sim_spawner`
  functions, not stubs; both spawn modules spawn clean and rely on the "Edit Injuries" selection
  flow (or, on AFCM Patient, an optional Injury Preset Import attribute) rather than randomizing.
  Eden previously also shipped AFCM MASCAL Zone/AFCM MCI Spawner/Medical Tent modules - removed on
  request, keeping just these two (§9). `requiredAddon` `afcm_sim_main`, `afcm_sim_scenario`, and
  `afcm_sim_spawner`.

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

**Implemented as a plain `Array`, not the `HashMap` this section originally sketched** — a
`HashMap` has no literal SQF syntax, so `str someHashMap` doesn't produce something `call compile`
can turn back into a `HashMap`, which export/import (§ Injury Presets below) depends on completely.
Full detail, real function names, and the built-in preset list: INJURY_CODES.md §4.

```
Preset = [id, name, author, description, injuries, tags]
// injuries: [[limb, woundType, severity, bleeding], ...] - the same 4 primitives
//           afcm_sim_scenario_fnc_serverApplyInjury already takes, not the full runtime Injury
//           object (bleedRate/tourniquetable/variables are derived at apply time, not stored)
// tags: [String], e.g. "GSW", "HE", "training-scenario-3"
```

Presets ship in two tiers: **built-in** (`afcm_sim_scenario_fnc_getBuiltinPresets`, packed in the
addon — gunshot wound, GSW w/ tourniquet, blast casualty, frag wounds, a minor training case) and
**user-saved** (`profileNamespace`, so mission makers and players build and re-share their own —
the "custom ones people have made and saved" requirement). User presets export/import as plain text
(`str _preset` / `call compile`) via a shared text field in the Preset Library UI, so they're
shareable outside the mission file — pasted into Discord, a text file, or another player's own
Import box.

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
  silhouette): limb buttons **toggle** on/off (`fnc_limbSelect_onLimbToggle.sqf`, recolored live via
  the real `ctrlSetBackgroundColor`) rather than navigating away on the first click — one or more
  can be selected before continuing. A separate "Apply Trauma to Selected Limb(s)" button (disabled
  with an explanation until at least one is toggled) publishes `limb.selected` with the whole
  selection and opens the injury editor below for all of them at once — `limb.selected` is
  consumed now, not a dead-end event.
- **Selectable Injuries** — per-limb injury editor (wound type, severity, bleed toggle, custom
  variables) → emits `injury.applied`/`injury.removed`. **Implemented, partially**: wound
  type/severity/bleeding are real (`RscDisplayAFCM_SIM_InjuryEditor`, `afcm_sim_ui`); severity is a
  4-band combo (Light/Moderate/Severe/Critical → 0.25/0.5/0.75/1.0), not a continuous slider.
  `variables` (custom free-form fields) not exposed in the UI. One wound configuration applies
  identically to every limb selected on the previous screen (`AFCM_SIM_UI_targetLimbs`, plural) —
  reachable a second way in Zeus specifically: dragging the "Edit Injuries" module
  (`AFCM_SIM_ModuleEditInjuries`, `curatorCanAttach = 1`) directly onto any unit opens this same
  flow immediately, without needing the addAction below to already exist on the target — grounded
  in ACE3's own "Heal" Zeus module (`attachedTo _logic` for the target, a `local _logic` guard so
  the dialog opens only on the placing curator's machine, then self-deletes) —
  a single Apply loops one `serverApplyInjury` request per limb, rather than repeating the whole
  flow per limb; Fracture (KAT) applies the same way, once per selected limb that's an arm or a
  leg specifically (control only shows, and server-side dispatch only accepts, arm/leg limbs —
  deliberately excludes head/chest even though KAT's own `kat_surgery_fractures` array has a slot
  for both, INJURY_CODES.md §6), while Pneumothorax (KAT, torso-wide) applies once total whenever
  "chest" is among the selection. Publishes
  `injury.applied` per limb; no removal path yet, so no `injury.removed`. Entry point is a vanilla
  `addAction` ("Edit Injuries") added to every spawned patient — not an ACE interaction-menu entry
  (REFERENCES.md documents that API as confirmed-but-unused, consistent with §2.4's decision to
  keep AFCM-Simulator's own UI ACE-independent). Apply routes through
  `afcm_sim_scenario_fnc_serverApplyInjury` → the same `afcm_sim_fnc_backend_applyInjury` dispatch
  the randomizer uses (DESIGN.md §6 — server-authoritative, never applied client-side). Also shows
  **live medical state** while open — a new `afcm_sim_fnc_backend_getState` dispatch (mirrors
  `applyInjury`'s pattern, read-only, safe from any machine) reports consciousness
  (`lifeState`/`incapacitatedState`), pain, whether the unit is injured at all, and the *first*
  selected limb's open-wound/bleeding state (getState is inherently per-limb; with more than one
  limb selected the readout says how many more are selected alongside it — consciousness/pain/
  injured stay accurate regardless); `afcm_sim_ace_compat` implements
  it via `ace_medical_fnc_isInjured`/`getOpenWounds` (both safe to call off the unit's owning
  machine, unlike `getBloodLoss` which requires `local _unit` and is deliberately not used here).
  Refreshed on a 0.5s `CBA_fnc_addPerFrameHandler` while the dialog is open, removed on close. A
  **Reset Limb** button here is purely local — clears the wound type/severity/bleeding fields back
  to their defaults (`fnc_injuryEditor_onReset.sqf`) without touching the patient's real medical
  state at all. Deliberately not a medical operation: ACE has no public API to heal just one body
  part (`ace_medical_fnc_fullHeal`'s own "Body Part" argument is documented "(unused)" in ACE3's
  real source, and its per-limb damage model tracks left/right arm/leg through custom internal
  state rather than simple settable native hitpoints — there's no supported, reliable way to scope
  a real heal to one limb). The real, full-unit reset lives one screen up instead: the limb-select
  ("main") screen's own **Reset Patient** button wipes everything done to the patient so far
  (wounds, bandages, drugs) via the `afcm_sim_fnc_backend_reset` dispatch —
  `afcm_sim_ace_compat`/`afcm_sim_kat_compat` both implement it as `ace_medical_fnc_fullHeal` (real,
  confirmed) followed by re-locking via the `setUnconscious` backend op
  (`ace_medical_fnc_setUnconscious`, not the engine command — see below), so a reset hands back the
  same "just spawned" baseline rather than a fully awake, healthy unit. Routes through
  `afcm_sim_scenario_fnc_serverReset`, same server-authoritative request pattern as Apply. It moved
  here (off the injury editor, where it used to live under the same "Reset Patient" label) because a
  whole-patient wipe read as misleadingly scoped to just the limb being edited. Neither Reset button
  closes its dialog — the live status readout on the injury editor shows the clean state within
  moments either way, and the instructor can immediately pick a fresh injury. Deliberately
  **wound type/severity/bleeding unconditionally** — nothing backend-specific there, since ACE and
  KAT both consume the exact same real calls identically underneath (ACE_COMPAT.md §3/
  KAT_COMPAT.md §3). The only backend-awareness for those three is a check against
  `afcm_sim_fnc_backend_getActive`: if nothing usable is active (nothing registered, or only `afcm`
  — not yet supported by this UI, DESIGN.md §2.5), Apply is disabled and the limb label explains why
  instead of offering controls that would silently no-op.
  On top of that, real, backend-conditional KAT-only **Fracture**/**Pneumothorax** controls
  (`kat_surgery_fractures`/`kat_breathing_pneumothorax`/`_hemopneumothorax`/`_tensionpneumothorax`,
  INJURY_CODES.md §6) are shown only when KAT is the active backend (Pneumothorax also only when the
  selected limb is "chest" — it's a torso-wide condition, not per-limb). An earlier pass built this,
  reverted it, then rebuilt it grounded directly against real KAT source
  (`kat_surgery_fnc_fractureSelectLocal`/`kat_breathing_fnc_handleBreathing`/
  `fnc_inflictAdvancedPneumothorax`, all fetched from `KAT-Advanced-Medical/KAM`) rather than a
  prior working prototype's comments — this pass confirmed the real severity scales (0-4 for
  pneumothorax; "Simple"/"Compound"/"Comminuted" for fracture, not "Stable" as previously
  documented) in the process. `afcm_sim_kat_fnc_applyFracture`/`applyPneumothorax` are called
  directly, not through the generic `Injury`/backend-interface dispatch, since neither concept fits
  that schema — Apply on the injury editor fires them alongside the regular wound application in
  one click, whenever the corresponding control is actually visible and not set to "None".
  - **Airway** (head) — added after Fracture/Pneumothorax, same real-source-grounded approach:
    `kat_airway_obstruction`/`kat_airway_occluded` (`afcm_sim_kat_fnc_applyAirway`), two
    mutually-exclusive Bools with genuinely different real treatment paths (Obstruction is what an
    airway adjunct clears; Occlusion explicitly rejects that treatment — needs a surgical airway),
    shown only when KAT is active AND "head" is among the selected limbs. INJURY_CODES.md §6 has
    the full real source citations.
  - **Hemothorax / blood volume** — picking Hemopneumothorax now also calls the real
    `kat_circulation_fnc_updateInternalBleeding` (a real bug fix — an earlier pass set the flag with
    no actual bleeding effect). The injury editor's live status readout gained **Blood Volume**
    (real `ace_medical_bloodVolume`, both ACE and KAT) and, KAT-only, **Internal Bleeding Rate**
    (real `kat_circulation_internalBleeding`, litres/second) whenever it's actually nonzero. KAT
    doesn't model a separate "chest cavity" blood pool — hemothorax drains the same whole-body
    volume faster, confirmed from real source, not guessed at (INJURY_CODES.md §6).
  - **Cardiac State** — unlike Fracture/Pneumothorax/Airway, **not** KAT-exclusive: cardiac arrest
    is genuinely ACE-native (`ace_medical_vitals_inCardiacArrest`, set via the real
    `ace_medical_status_fnc_setCardiacArrestState`), doubly confirmed since KAT's own repo vendors
    the identical ACE header rather than defining its own arrest flag. `afcm_sim_ace_fnc_
    applyCardiacState` exists in `ace_compat` for this reason, not just `kat_compat`. KAT layers a
    real rhythm type on top (`kat_circulation_cardiacArrestType`, 0=Normal/1=Asystole/2=PEA/
    3=Ventricular Fibrillation/4=Ventricular Tachycardia, confirmed from KAT's own
    `fnc_handleCardiacArrest.sqf`) — only visibly affects behaviour if the mission has KAT's own
    "Advanced Cardiac Rhythm" setting enabled, harmless real state either way. Exposed as one
    Cardiac State combo, shown for either backend, gated on "chest" being among the selected limbs
    — same gating as Pneumothorax, even though the real `ace_medical_vitals_inCardiacArrest` flag
    is actually whole-patient, since chest is where an instructor thinks to look for it.
    `afcm_sim_kat_fnc_reset` also explicitly clears the KAT rhythm variable, which `fullHeal` has no
    knowledge of — same class of gap fixed for Fracture/Pneumothorax/Airway. Full real source
    citations: INJURY_CODES.md §7.
- **Injury Presets** — built-in + user library, save/load/export/import, apply-to-selected-unit.
  **Implemented**, in `afcm_sim_scenario` (data/logic) + `afcm_sim_ui` (Preset Library/Preset Save
  dialogs). A Preset is a plain `Array`, not the `HashMap` §4.3 originally sketched — `str _preset`
  round-trips reliably through `call compile` for export/import; `str` on a `HashMap` doesn't
  reconstruct one, since HashMaps have no literal SQF syntax — so every preset (built-in and
  user-saved) is `[id, name, author, description, injuries, tags]`, where `injuries` is an Array of
  `[limb, woundType, severity, bleeding]` (the same 4 primitives `serverApplyInjury` already takes,
  DESIGN.md §4.1/§4.2). 5 built-in presets ship with the addon
  (`afcm_sim_scenario_fnc_getBuiltinPresets`, id prefix `builtin_`); user presets persist per-player
  in `profileNamespace` (`afcm_sim_scenario_fnc_getUserPresets`/`saveUserPreset`/`deleteUserPreset`,
  survives mission/game restarts, real `saveProfileNamespace` flush). Export/Import
  (`fnc_exportPreset.sqf`/`fnc_importPreset.sqf`) share one `RscEdit` text field in the Preset
  Library dialog — Export fills it and copies to the OS clipboard (`copyToClipboard`), Import reads
  whatever's typed/pasted into it (native OS paste, nothing scripted needed for that half) and
  always assigns a fresh id rather than trusting the pasted one. Apply loops
  `afcm_sim_scenario_fnc_serverApplyPreset` → `serverApplyInjury` per injury, same
  server-authoritative request pattern as manual application (DESIGN.md §6) — reuses
  `serverApplyInjury` directly rather than duplicating its Injury-construction logic. "Save as
  Preset" (a button on the injury editor) captures the currently-configured wound as one entry per
  selected limb (§ Selectable Body Limbs above — the same multi-limb toggle Apply uses), so a
  *multi*-injury preset built from scratch (several limbs, same wound, saved together) is possible
  directly from the injury editor now, not just from the 5 built-in presets — deliberately not
  Fracture/Pneumothorax/Airway though, which have no place in this Array shape (INJURY_CODES.md §6,
  same reason they're applied via a separate direct call). A dedicated "preset builder" cart flow (mixing
  *different* wounds across limbs into one save, not just one wound broadcast to several) is still a
  natural next step if this gets more use. **Validated on read** (full-codebase review) — since
  `profileNamespace` is user-editable/persistent data, `getUserPresets`/`getUserMciPresets` now
  filter out any entry that isn't a well-formed Array with a real String id before returning it,
  instead of trusting whatever's stored blindly; `saveUserPreset`/`deleteUserPreset` (and their MCI
  counterparts) now read through those same getters rather than the raw `profileNamespace` variable,
  so a single malformed entry can no longer wedge reading, saving, deleting, *and* importing all at
  once the way it used to — it's just dropped, and self-heals on the next write.
- **Export Patient State** — export one live, hand-authored patient's current AFCM-applied
  injuries as a Preset string, reusable in the AFCM Patient module's Injury Preset Import attribute
  (above) or the Preset Library's own Import field — the building block for authoring a custom MCI
  entirely out of individually-configured patients. **Implemented**, in `afcm_sim_scenario` +
  `afcm_sim_ui`. `afcm_sim_fnc_backend_applyInjury` (owned by `afcm_sim_main`, the one real choke
  point every injury application already goes through regardless of source — manual, preset,
  randomized, MCI) tracks one `[limb, woundType, severity, bleeding]` tuple per limb on the unit
  itself (`AFCM_SIM_appliedInjuries`, `publicVariable`'d, a fresh apply on a limb overwriting its
  own tracked entry rather than appending) — there's no reliable way to reverse-map live ACE/KAT
  wound state back into this addon's own simplified woundType strings, so it's captured at the
  point of application instead. KAT-only extras/cardiac state (fracture/pneumothorax/airway/
  cardiac rhythm) ARE captured too, but read straight from live state instead
  (`kat_surgery_fractures`/`kat_breathing_pneumothorax`(+hemo/tension)/`kat_airway_obstruction`
  (+occluded)/`kat_circulation_cardiacArrestType`, falling back to the plain ACE
  `ace_medical_vitals_inCardiacArrest` flag when no KAT rhythm is set) — these are AFCM/KAT's own
  custom variables, not part of ACE's generic wound system, so unlike base injuries there's no
  reverse-mapping problem to work around. `afcm_sim_scenario_fnc_exportPatientState` wraps both in
  the same `[id, name, author, description, injuries, tags]` shape/`str` round-trip as
  `fnc_exportPreset.sqf`, **plus a new optional 7th element**, `katExtras` (`[fractures <ARRAY[6]>,
  pneumothoraxType, airwayType, cardiacRhythm]`) — omitted entirely when every value is at its
  "clear" default, so a pure-ACE export still looks like every other 6-element Preset. A new "AFCM:
  Export Patient State" scroll action (every spawned patient gets it,
  `afcm_sim_spawner_fnc_spawnPatient`) copies the result straight to the OS clipboard
  (`copyToClipboard`, same mechanism the Preset Library's own Export uses).

  The reverse direction — parsing an exported string back into clean injuries + katExtras — is
  factored out of `fnc_importPreset.sqf` into `fnc_parseExportedPreset.sqf` specifically so the
  AFCM Patient module's spawn-time import and the Preset Library's save-to-library import share one
  validated parser instead of two copies of the same logic. Applying katExtras itself is factored
  into `afcm_sim_scenario_fnc_serverApplyKatExtras` (dispatches to the same
  serverApplyKatFracture/serverApplyKatPneumothorax/serverApplyKatAirway/serverApplyCardiacState
  handlers the injury editor's own controls use — each already no-ops safely under a non-KAT
  backend), reused by `fnc_serverApplyPreset.sqf` (Preset Library Apply, including the MCI batch
  path) and `afcm_sim_spawner_fnc_spawnPatient` (the AFCM Patient module's spawn-time import). A
  preset carrying only katExtras and no base injuries (e.g. "just a cardiac arrest, no wound") is a
  valid export/import on its own — export/parse both check injuries-empty-AND-katExtras-empty, not
  either alone. **Scope note**: `fnc_getBuiltinPresets.sqf`'s built-ins and the injury editor's own
  "Save as Preset" button still only carry base injuries — katExtras only ever originates from
  Export Patient State right now, not from hand-building a preset in the Preset Library UI.
- **Injury Levels (Randomization)** — pick a level → domain logic rolls a concrete injury set from
  that level's profile → applies via the same `injury.applied` path presets use (one application
  pipeline, three sources: manual, preset, randomized). **Implemented**:
  `afcm_sim_scenario_fnc_randomizeInjuries` rolls a real Injury array per the §4.4 profile table.
  All three sources in the "one pipeline, three sources" framing are real now: manual (the injury
  editor), preset (just above), randomized (this one) — each ultimately reaches the same
  `afcm_sim_fnc_backend_applyInjury` dispatch.
- **Spawn Patient (Zeus)** — spawns a clean, unconscious patient at the module's position; the Zeus
  operator then picks the actual injury via the "Edit Injuries" scroll action every spawned patient
  gets (§ Selectable Injuries above), rather than a random roll. **Implemented**:
  `afcm_sim_spawner_fnc_spawnPatient` called directly (no injuries argument), `disableAI "ALL"` set
  on the unit so it can't do anything autonomously. Patients "healing themselves" took four rounds
  of investigation to actually pin down — see REFERENCES.md for the full history. Root cause
  (confirmed): the unit was being knocked out with the vanilla `setUnconscious` command, which only
  changes ragdoll/animation state; ACE tracks consciousness independently via its own
  `"ACE_isUnconscious"` variable, which `ace_medical_ai`'s state machine (ticks over every
  locally-known unit, entirely independent of `disableAI`) actually checks before letting a unit
  self-treat. Fix: a new `setUnconscious` backend op wrapping the real
  `ace_medical_fnc_setUnconscious`, used both at spawn time and by a recurring
  `CBA_fnc_addPerFrameHandler` safeguard (every 3s, for as long as the specific unit exists) that
  re-asserts it regardless of what might try to wake the unit. This means a patient won't wake up
  even from fully successful real treatment until an instructor explicitly resets it
  (`afcm_sim_fnc_backend_reset`) — accepted as the right trade-off for a training tool where
  "spontaneously recovers on its own" was never the intended behaviour either way.
  `AFCM_SIM_ModuleSpawnRandomPatient` internally (display name is now just "Spawn Patient" —
  renaming the class would orphan it in any mission that's already placed one).
  `afcm_sim_spawner_fnc_spawnRandomPatient` (the randomizer wrapper `afcm_sim_scenario_fnc_
  randomizeInjuries` fed) was removed along with its one real caller, AFCM MASCAL Zone (§9) — dead
  code once that module was gone, per this repo's own "remove rather than orphan" convention.
  `randomizeInjuries` itself is still real and still called elsewhere (`resolveMciPatientSpec`'s
  `"random"` branch). Casualty appearance is configurable, not random: a
  "Casualty Type" module attribute (Civilian/Military BLUFOR/Military OPFOR/Military Independent,
  real base-game classnames `C_man_1`/`B_Soldier_F`/`O_Soldier_F`/`I_Soldier_F` — no faction mod
  dependency) picks the spawned classname, falling back to the `afcm_sim_defaultCasualtyType` CBA
  Addon Option when unset. Whatever's picked, `spawnPatient` always strips the unit down to bare
  clothing (`removeAllWeapons`/`removeAllItems`/`removeAllAssignedItems`/`removeVest`/
  `removeBackpack`/`removeHeadgear`/`removeGoggles`) — a patient is a casualty prop, not a
  combatant, so it never spawns carrying a weapon or gear of its own even when the military
  classnames' default combat loadout would otherwise include one.
- **AFCM Patient (Eden)** — design-time patient placement for scripted scenarios: a mission maker
  places the module, and it spawns a patient on mission start (`afcm_sim_eden`), clean/unconscious
  by default — same "Edit Injuries" selection flow as Zeus's Spawn Patient, not a random roll.
  Distinct from Spawn Patient (Zeus, live) and Map to Spawn Patients (below, in-mission) — this is
  the pre-authoring path. **Implemented**: calls `spawnPatient` directly. The module's old "Injury
  Level" attribute is gone (eden/config.cpp) — it stopped doing anything once this module stopped
  auto-randomizing. It keeps its own "Casualty Type" attribute (same four options as Zeus's, shared
  `AFCM_SIM_CasualtyTypeAttributes` base class) — purely cosmetic, so it's independent of the
  injury-randomization pipeline the old attribute controlled. Hidden from Zeus's own curator module
  browser (`scopeCurator = 0;`) since Zeus already has its own live "Spawn Patient" doing the same
  job — showing both used to just clutter the Zeus module list.

  Two attributes make this module a real building block for hand-authoring a custom MCI one
  patient at a time (§ Export Patient State, below):
  - **Injury Preset (paste to import)** — paste an exported Injury Preset or Patient State string
    (`fnc_exportPreset.sqf` / `fnc_exportPatientState.sqf` — same shape) to spawn this patient
    pre-configured with those exact injuries instead of clean/unconscious. Parsed by the shared
    `afcm_sim_scenario_fnc_parseExportedPreset` (also used by the Preset Library's own Import), so
    it accepts anything either one produces.
  - **Spawn Marker Name** (text) — where the patient actually spawns. Precedence: any object synced
    to the module (Eden: Ctrl+click drag a sync line to it) always wins; otherwise a non-blank
    marker name that resolves to a real placed marker; otherwise (both left alone) the original,
    still-default behaviour, the module's own placed position. Real, confirmed bug fixed here: an
    earlier pass required a separate "Spawn at Synced Object" checkbox to be ticked before a sync
    would take effect at all, so simply syncing an object with the checkbox left at its default
    silently fell through to the module's own position — that checkbox is gone now, sync alone just
    works.
- **Stretcher Placement** — selectable stretcher type (class list sourced from whichever backend
  is active, §2.5), ghost-preview placement (surface-snapped, like Zeus placement), spawns synced
  for MP. *Not implemented.*
- **Map to Spawn Patients / MCI Spawner** — pick a place on the map, pick a preset, batch-spawn a
  Mass Casualty Incident. **Implemented**: a Zeus module below, plus the **MCI Creator** further
  down (§ MCI Creator — a real, literal interactive map-click tool, standalone, not tied to module
  placement, where every patient in the incident can carry a *different* preset).
  - **MCI Spawner (Zeus, `AFCM_SIM_ModuleMciSpawner`)** — placing the module spawns Patient Count
    clean, unconscious patients at that position (loosely scattered via `spawnPatient`'s own
    jitter), then adds an "Assign MCI Preset" scroll action to the whole batch. Clicking it on any
    one of them opens the real Preset Library (`RscDisplayAFCM_SIM_PresetLibrary`, § Injury
    Presets) in batch mode (`AFCM_SIM_UI_targetUnits`, plural) — picking a preset there applies it
    to every patient in the group at once, in one Apply. Deliberately doesn't try to pop the dialog
    straight from the module function itself: Module_F functions run with `isGlobal = 1` (broadcast
    to every connected machine — every module in this addon already needs its own `isServer` guard
    for exactly that reason), so there's no reliable way to know which one client's curator actually
    placed it and should see a dialog. The addAction route sidesteps that entirely, reusing the
    same already-proven, inherently per-client-local mechanism "Edit Injuries" uses — full built-in
    *and* the placing operator's own saved presets are reachable this way, live.
  - **AFCM MCI Spawner (Eden)** and **AFCM MASCAL Zone** (the design-time, static-preset/randomized
    batch-spawn counterparts to the above) were both removed on request (§9), along with Medical
    Tent — Eden's module list is now just AFCM Patient + Interactive Terminal. Zeus's MCI Spawner
    above and the MCI Creator below still cover live/ad-hoc batch spawning.
- **MCI Creator** — the standalone tool for when patients need genuinely *different* injuries from
  each other in the same incident (module MCI Spawners above give every patient the same preset;
  this is the "a HE shell hit a section, 3 are down, but with different injuries" case). Callable
  directly (`call afcm_sim_ui_fnc_mciCreator_open;`) and bound to a real CBA keybind (default
  Ctrl+Shift+M, rebindable in Configure > Controls > Addon Bindings — `afcm_sim_main`'s
  `fnc_registerMciCreatorKeybind.sqf`), so it doesn't need a module placed first at all.
  **Implemented**:
  - **Patient list** (`RscDisplayAFCM_SIM_MciCreator`) — a Patient Count combo (1-10) drives a
    working `AFCM_SIM_UI_mciPatientSpecs` Array (one entry per patient — a real Preset id, or the
    literal string `"random"`). A second listbox shows every available Preset ("Random" first,
    then built-in, then the player's own saved ones); selecting one there and a patient on the
    left, then clicking Assign, sets just that patient's spec — independently of every other
    patient's. "Randomize All Patients" resets every slot back to `"random"` in one click.
  - **Real map-click placement** (`RscDisplayAFCM_SIM_MapPicker`) — not a grid of buttons: a
    genuine `RscMapControl` (the same base class the vanilla in-mission map screen and countless
    custom marker-placement tools use), with a real `MouseButtonDown` handler converting the click
    to a world position via the real `ctrlMapScreenToWorld` command, and drops a real local marker
    there (`createMarkerLocal`/`setMarkerPosLocal` — client-side only, never synced, purely a UI
    preview aid; moved on subsequent clicks rather than recreated, cleaned up on close either way
    via `fnc_mapPicker_cleanup.sqf`'s `onUnload`) so the pick is visible directly on the map, not
    just as text. Shows the picked grid reference (`mapGridPosition`) too, so there's confirmation
    of exactly where Confirm will place the incident. Spawn MCI stays disabled until a location has
    actually been picked.
  - **MCI Presets** (`RscDisplayAFCM_SIM_MciPresetLibrary`/`MciPresetSave`) — a *second*, separate
    preset library from the single-injury one above: an MCI preset is
    `[id, name, author, description, patientSpecs]`, where `patientSpecs` is an Array of Preset
    ids/`"random"`, one per patient — a named, reusable **incident**, not a single injury. 3
    built-in examples ship with the addon ("HE Shell — 3 Casualties", "IED Strike — 4 Casualties",
    "Ambush — 2 Casualties"; `afcm_sim_scenario_fnc_getBuiltinMciPresets`), plus the same real
    `profileNamespace` user-library + plain-Array `str`/`call compile` export/import pattern as
    single-injury Presets (§ Injury Presets) — including on Import, where patient specs that
    reference a Preset id the importing player doesn't have saved themselves are dropped rather
    than rejecting the whole MCI preset, since that's a real, expected case when sharing between
    players, not corruption. "Random" specs are never baked in — resolved fresh
    (`afcm_sim_scenario_fnc_resolveMciPatientSpec`) every time the incident is actually spawned,
    whether that's right after building it or hours later after loading a saved MCI preset.
  - **Spawn** (`afcm_sim_scenario_fnc_serverSpawnMci`) — one remoteExec'd request carrying the
    position, the patient specs, and a Casualty Type (shared across the whole incident, same as the
    module version). Resolves each patient's spec independently
    (`afcm_sim_scenario_fnc_resolveMciPatientSpec` → `afcm_sim_scenario_fnc_buildInjury`) and calls
    the same `afcm_sim_spawner_fnc_spawnPatient` every other spawn path already uses — no new
    spawning logic, just a new way to assemble the injuries going into it.
- **Clear spawned patients / Spawn Sessions** — not in the original feature list; added after
  reviewing a prior working prototype (REFERENCES.md) that needed exactly this. **Implemented**,
  including the per-spawner/session-scoped clearing the prototype had that an earlier pass here
  didn't yet build: every batch of patients spawned together (a Zeus MCI Spawner, an MCI Creator
  incident) is grouped into one named **Spawn Session**
  (`afcm_sim_spawner_fnc_spawnPatient`/`newSessionId`) — `[id, label, spawnTime, units]`, tracked
  in `AFCM_SIM_spawnSessions` alongside the existing flat `AFCM_SIM_spawnedPatients` list (which
  still covers every patient regardless of session). Single-patient spawns (Zeus "Spawn Patient",
  Eden "AFCM Patient") each get their own automatic one-patient session, no caller changes needed -
  only batch spawners generate one id up front and pass it to every patient in their loop.
  `afcm_sim_spawner_fnc_serverDeleteSession` deletes one session's patients only, leaving every
  other session's untouched - the actual ask this covers: two medics can each be working their own
  MCI at once, and clearing one doesn't touch the other's. The **Session Manager**
  (`RscDisplayAFCM_SIM_SessionManager`, `afcm_sim_ui_fnc_sessionManager_open` - callable directly,
  bound to a real CBA keybind default Ctrl+Shift+O, and reachable from the MCI Creator's own
  "Manage Sessions" button) lists every active session ("label — N patients, spawned Xm ago") and
  can delete the selected one. `afcm_sim_spawner_fnc_clearAllPatients` (the original global "clear
  all," now also clearing `AFCM_SIM_spawnSessions`) stays as the Session Manager's own "Clear All
  Sessions" button - deliberately the *only* destructive action in this whole UI kit gated behind a
  real Yes/No confirmation (a new generic, reusable `RscDisplayAFCM_SIM_ConfirmDialog`,
  `afcm_sim_ui_fnc_confirmDialog_open` - any future destructive action can reuse it), since it's
  the one action with no per-session scoping at all.
  **The prototype's actual technique**, confirmed from its full source (`med_sim.sqf`, REFERENCES.md):
  a `HashMap` keyed by a composite session id string — `"{spawnerNetId}|L{level}|C{count}|{timestamp}"`
  — built fresh per spawn call, with a clear function that filters keys by matching `spawnerNetId`
  prefix, then either clears just the most-recent-timestamp match ("last") or every match ("all")
  for that specific spawner. This implementation uses a simpler scheme instead - a freshly
  generated `session_<tickTime>_<counter>` id per batch, explicit rather than derived from
  `spawnerNetId` - since the batch spawner itself already knows exactly which patients are its own
  without needing to reconstruct that from the id string. The counter (`AFCM_SIM_sessionIdCounter`,
  always-incrementing) replaced an earlier `<tickTime>_<random>` scheme after the review found a
  real, if small, collision chance — two batch spawns landing in the same server tick could
  generate the identical id, silently merging two unrelated incidents into one session entry. Same
  fix applied to user preset/MCI preset ids (`fnc_saveUserPreset.sqf`/`saveUserMciPreset.sqf`),
  where a collision would have silently overwritten an unrelated saved preset instead of merely
  merging.
  **Custom session names** — every batch spawn path (Zeus/Eden Spawn Patient, Zeus MCI Spawner, and
  the MCI Creator dialog) now reads an optional free-text label
  and uses it verbatim in place of the auto-generated one when non-blank, so the Session Manager
  list can show something meaningful ("Breach team casualties") instead of only "MCI Spawner — 6
  patients". Zeus/Eden modules expose this as a shared `AFCM_SIM_SessionName` Eden Attribute
  (`control = "Edit"`, `typeName = "STRING"` — confirmed against the official BI wiki's Eden Editor
  attribute docs, REFERENCES.md); the MCI Creator dialog exposes the same thing as a plain
  `RscEdit` field next to Patients/Casualty Type, read in `afcm_sim_ui_fnc_mciCreator_onSpawn` and
  forwarded to `afcm_sim_scenario_fnc_serverSpawnMci`'s new optional 4th argument. Blank always
  falls back to the same auto-generated label each path already had — no behaviour change for
  anyone who leaves the field empty.
- **Medical Tent** — not in the original feature list; a session-scoped treatment-completion check
  built on top of Spawn Sessions, not a spawned/scripted physical object. AFCM deliberately doesn't
  build or spawn any scenery for this (tent, screens, gear) — the mission maker builds that
  themselves out of real objects, however elaborate they want (a normal Eden Composition is the
  recommended way, since it's real classnames + relative positions the mission maker picks visually,
  with zero classname-guessing risk on AFCM's side either way). All AFCM needs from that scenery is
  which objects act as stretchers.
  - **Currently unreachable**: its one placement module, `AFCM_SIM_ModuleMedicalTent` (Eden), was
    removed on request (§9) along with AFCM MASCAL Zone/AFCM MCI Spawner (Eden) — no Zeus
    equivalent was ever built, so there's no other way to register a tent's synced stretchers right
    now. The scenario-layer logic below is all still real, working code, just currently with
    nothing left to call it — reachable again if a new entry point (Zeus module, or re-adding the
    Eden one) is ever wanted.
  - **Placement (removed)**: `AFCM_SIM_ModuleMedicalTent` used to sync any stretcher-ish objects to
    it (naming each one `afcm_stretcher_1`/`afcm_stretcher_2`/etc in Eden's own object Name field
    first was the recommended convention, purely for the mission maker's/AFCM's own log readability
    — not parsed by the code, membership came from the sync line itself, so any classname worked). A
    "Stretcher Radius (m)" attribute (default 2) set how close a patient had to be to count as on
    one.
  - **Detection is session-scoped, not tent-scoped**: `afcm_sim_scenario_fnc_registerMedicalTent`
    adds a module's synced stretchers to one shared global list
    (`AFCM_SIM_medicalStretchers`) and lazily starts a single shared monitor loop
    (`afcm_sim_scenario_fnc_startMedicalTentMonitor`, plain server-side `spawn`/`sleep 5` — no
    per-frame precision needed) the first time any tent registers, rather than one loop per tent.
    Every 5s it checks every still-live unit in every `AFCM_SIM_spawnSessions` entry against every
    registered stretcher (from any tent) at once. A session resolves the moment every one of its
    live patients is simultaneously **treated**
    (`afcm_sim_scenario_fnc_isPatientTreated`) and **on a stretcher**
    (`afcm_sim_scenario_fnc_isPatientOnStretcher`) — this is what makes multiple simultaneous tents
    "free" and independent: two medics' own MCIs (their own Spawn Sessions, already isolated per
    § Spawn Sessions above) resolve on their own regardless of how many tents exist or which one
    each medic used.
  - **"Treated" is both auto-detected and manually overridable** (deliberately "Both", not either
    alone — auto-detect can't cover every backend/situation, e.g. no medical backend active at all):
    auto-detect is `lifeState == "ALIVE"` (vanilla engine command) AND no limb reporting
    `limbBleeding` via the existing `afcm_sim_fnc_backend_getState` (DESIGN.md §4.2's live-status
    API, looped once per limb since that field is inherently per-limb) — reuses the exact same
    real getter the Injury Editor's own live status readout already calls, no new backend surface.
    The manual half is a new "Mark as Treated" addAction every spawned patient gets alongside "Edit
    Injuries" (`afcm_sim_ui_fnc_addTreatedAction`), remoteExec'ing a server-authoritative setter
    (`afcm_sim_scenario_fnc_serverMarkTreated`, same DESIGN.md §6 server-authority pattern as every
    other state change here) that sets `AFCM_SIM_treated` on the unit.
  - **Notification**: a real, confirmed vanilla non-modal HUD overlay
    (`RscTitles`/`cutRsc`, `community.bistudio.com/wiki/cutRsc` — deliberately not another
    `createDialog`-based dialog, since a real interactive display would compete for input focus with
    the Zeus interface or whatever the viewer already has open), custom AFCM-branded
    (`RscDisplayAFCM_SIM_Toast`, same colour palette as the rest of the UI kit). Shown via a generic,
    reusable `afcm_sim_ui_fnc_showToast` helper — any future AFCM event can reuse it, same as
    `ConfirmDialog` is reused for destructive actions. The resolved-session handler
    (`afcm_sim_ui_fnc_notifySessionResolved`) also republishes `"session.resolved"` on the existing
    UI event bus (`afcm_sim_ui_fnc_publish`, same mechanism `injury.applied`/`limb.selected` already
    use) so a mission's own AAR/scoring logic — or a future scoreboard — can subscribe without AFCM
    needing to know what "end the scenario" means for that particular mission.
  - **Explicitly out of scope for this pass** (the user's own stated longer-term goal, not started):
    a full per-player scoreboard (items used, who treated whom, a score), an external companion mod
    that exports that data, and a public/private website with APIs for other units to consume it.
    That's a separate infrastructure project — hosting, auth, a public-facing API surface — that
    needs its own scoping conversation (stack, hosting, access control) rather than guessed-at
    choices bolted onto the Arma mod itself. `"session.resolved"` on the event bus above is the
    intended hook point once that work actually starts: whatever ends up building the export layer
    subscribes there instead of AFCM needing to know about it in advance.
  - **Three real edge cases fixed** (full-codebase review): a Medical Tent module fired with zero
    synced stretchers used to register silently, with no diagnostic anywhere pointing at the real
    cause when its sessions then never resolved — now logs and skips registration. A stretcher
    object destroyed mid-mission used to leave a stale entry every future check ran `distance`
    against forever — the monitor loop now prunes null stretchers once per cycle. A session whose
    every patient died before being treated used to be silently skipped every cycle forever,
    staying "pending" in the Session Manager with no way to ever resolve — it's now added to the
    same stop-checking set as a genuinely resolved session, but deliberately without firing the
    resolved notification, since nothing was actually treated.

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
- **"Server-side" isn't always literally the server**: `ace_medical_fnc_addDamageToUnit` requires
  `local _unit` (REFERENCES.md, confirmed from ACE3's own source) — a real constraint the
  server-authoritative request path above doesn't satisfy on its own, since the server isn't
  guaranteed to be local to every unit (a live player-controlled casualty, most notably). Real fix,
  not guessed at: `ace_compat`/`kat_compat`'s `applyInjury` dispatch the actual ACE calls via a
  shared CBA event (`"afcm_sim_applyAceStyleInjuryLocal"`, `CBA_fnc_targetEvent`) targeting the
  unit, so the work genuinely runs on whichever machine is local to it — the same real mechanism
  KAT's own source uses for the same problem (its "...Local"-suffixed treatment functions). "Server
  decides, then dispatches to the right machine to actually execute" is the accurate description of
  this path, not "the server does it."
- **JIP**: preset library (built-in) is static per-addon-version, so no JIP concern — and, now that
  it's actually implemented, this turned out to apply to user presets too: they live in each
  player's own `profileNamespace`, computed locally from a function call rather than synced state,
  so there's genuinely nothing to re-send a late-joiner at all (DESIGN.md § Injury Presets). Any
  in-progress MASCAL spawn batches are the one thing here that would still need a JIP path if
  that ever becomes stateful beyond "spawn N patients once on mission start."
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
    eden/          # afcm_sim_eden — "AFCM Patient"/"Interactive Terminal" Eden modules (§5), implemented
                    # requiredAddons = {cba_main, afcm_sim_main, afcm_sim_scenario, afcm_sim_spawner}
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
    INJURY_CODES.md    # §4 - the real preset export/import format (turned out small enough
                       # not to need its own doc file after all)
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
- **v1.x** — `afcm_sim_afcm_compat` gets built (a fresh PBO, not a scaffold sitting idle in the
  repo — an earlier empty config-only stub was removed rather than maintained with nothing to
  point at) once AFCM's `PatientState` API (§8 open question #2) is stable enough to build against
  — likely tracking AFCM's own v1/v2, not gated on AFCM-Simulator's own version number.
  `afcm_sim_kat_compat` is real now — `applyInjury`/`getState` implemented, `removeInjury` still a
  stub. `afcm_sim_acm_compat` lands once its real `requiredAddons` target is confirmed (§8 #1).
- **v2** — ~~injury presets (built-in + user save/load)~~ **done** (DESIGN.md § Injury Presets,
  incl. export/import — pulled forward from v3 below once it turned out `str`/`call compile` on a
  plain Array made that nearly free); randomization levels (done); Random Patient (incl. making the
  `afcm_sim_zeus` module real — done); stretcher placement — implemented once against the backend
  interface, so every active backend gets them simultaneously rather than one at a time.
- **v3** — ~~map spawn tool~~ **done early, three ways**: a Zeus+Eden module pair
  (`AFCM_SIM_ModuleMciSpawner`/`AFCM_SIM_ModuleMciSpawnerPlacement`, one shared preset per batch)
  *and* a genuine, literal interactive map-click tool (the MCI Creator, § MCI Creator — a real
  `RscMapControl`, per-patient independent presets, standalone/not tied to module placement).
  MASCAL batch placement (done — `AFCM_SIM_ModuleMascalZone`), ~~preset import/export/sharing~~
  (done early, see v2 — MCI presets too, § MCI Creator), making the `afcm_sim_eden` module real
  (done — `AFCM_SIM_ModulePatientPlacement`/`AFCM_SIM_ModuleMascalZone`/
  `AFCM_SIM_ModuleMciSpawnerPlacement`).
- **Eden module list trimmed** — `AFCM_SIM_ModuleMascalZone`/`AFCM_SIM_ModuleMciSpawnerPlacement`/
  `AFCM_SIM_ModuleMedicalTent` removed on request, keeping just `AFCM_SIM_ModulePatientPlacement`
  ("AFCM Patient") and `AFCM_SIM_ModuleInteractiveTerminal`. Function files deleted outright, not
  hidden; `afcm_sim_spawner_fnc_spawnRandomPatient` went with MASCAL Zone (its one real caller).
  Zeus's own MCI Spawner/MASCAL-equivalent-via-randomizeInjuries and the MCI Creator UI are
  unaffected and still cover live/ad-hoc batch spawning; Medical Tent has no other entry point left
  (§ Medical Tent above). AFCM Patient's own position resolution was also fixed in the same pass —
  syncing an object to it now just works, instead of silently requiring a since-removed "Spawn at
  Synced Object" checkbox to be ticked first.
- **Phase-2 spike (parallel, inside AFCM-Simulator)** — overlay-window proof of concept, evaluated
  independently; only promoted to "supported" if the hard problems in §2.3 are actually solved.

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
