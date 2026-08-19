<div align="center">

<img src="assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../README.md) · **Design** · [AFCM/Terminology](https://github.com/A3-TasmanDynamics/AFCM/blob/main/docs/TERMINOLOGY.md)

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

- **`afcm_sim_ui`, `afcm_sim_scenario`, `afcm_sim_spawner`** — `requiredAddons = {"cba_main"}`
  only. No mention of AFCM, ACE3, KAT, or ACM anywhere in these PBOs' configs. They call a small
  internal **backend interface** (a fixed set of function names, e.g. `afcm_sim_fnc_backend_applyInjury`)
  rather than calling AFCM or ACE3 directly — they have no idea which backend is actually active.
- **`afcm_sim_backend_afcm`** (new addon) — `requiredAddons = {"cba_main", "afcm_main"}`. Only
  loads if AFCM is present. Implements the backend interface against AFCM's `PatientState` API and
  registers itself as an available backend on `postInit`.
- **`afcm_sim_backend_ace`** (replaces the old single `afcm_sim_compat`) — `requiredAddons =
  {"cba_main", "ace_medical_engine"}`. Only loads if ACE3 is present. Implements the backend
  interface against `ace_medical_engine` hitpoints, and internally detects KAT/ACM at `postInit`
  (via `isClass (configFile >> "CfgPatches" >> "kat_medical")`-style checks, not separate PBOs,
  since they're enhancements to this same backend rather than alternate backends) to use their
  extended wound/treatment calls when present.
- **Selection priority** at `postInit`: if `afcm_sim_backend_afcm` registered, use it (native path
  preferred). Else if `afcm_sim_backend_ace` registered, use it (compat path). Else — no medical
  mod is present at all — `afcm_sim_scenario`'s injury-application actions disable themselves with
  a clear "no medical backend detected" message rather than silently no-op-ing or erroring.
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
   ├─ requires        ─→ CBA_A3 (only hard dependency)
   ├─ soft, either/both ─→ AFCM              (activates afcm_sim_backend_afcm)
   └─ soft, either/both ─→ ACE3 [+KAT / +ACM] (activates afcm_sim_backend_ace)
```

Everything this tool needs beyond a chosen backend — dialog framework, event bus, scenario/domain
logic — lives inside AFCM-Simulator's own addons (§7), backend-agnostic by construction (§2.5).
The internal split:

- **`afcm_sim_ui`** owns the **dialog framework** (native-dialog component kit: buttons, sliders,
  limb-diagram hit-areas, dropdowns, list boxes — styled once, reused across every screen) and the
  **event bus** used to decouple "UI raised an intent" from "domain logic executed it," so a
  Phase-2 overlay could later publish/subscribe to the same bus without a rewrite.
- **`afcm_sim_scenario` / `afcm_sim_spawner`** own: injury presets, randomization profiles, patient
  spawner, stretcher placement, the map tool — and call the **backend interface** (§2.5), never
  AFCM or ACE3 directly.
- **`afcm_sim_backend_afcm`** / **`afcm_sim_backend_ace`** (§2.5) — the two interchangeable backend
  implementations. Each is isolated precisely so either can be deleted without touching anything
  else if it's ever not worth maintaining.

---

## 4. Data Model

### 4.1 Body limb selection
The `LimbId` set below is the backend-agnostic vocabulary the UI/scenario layer actually uses.
Each active backend (§2.5) maps it to its own target internally — the scenario layer never sees
an AFCM site or an ACE3 hitpoint directly, only a `LimbId`:

| AFCM-Simulator `LimbId` | `afcm_sim_backend_afcm` target | `afcm_sim_backend_ace` target (ACE3 hitpoint) |
|---|---|---|
| `head` | AFCM head site | `HitHead` |
| `torso` | AFCM torso site (chest/abdomen split via `woundType`) | `HitBody`, `HitNeck` |
| `armLeft` / `armRight` | AFCM left/right arm site | `HitLeftArm` / `HitRightArm` |
| `legLeft` / `legRight` | AFCM left/right leg site | `HitLeftLeg` / `HitRightLeg` |

> The ACE3-hitpoint column needs verification once KAT's source is vendored/checked out locally —
> only blocks `afcm_sim_backend_ace`, not `afcm_sim_backend_afcm`.

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
DESIGN.md §2.1/§3) for `afcm_sim_backend_afcm` so "Hard" reliably feels harder inside the Lethal
Triad engine, and separately against KAT's/ACM's severity/treatment thresholds for
`afcm_sim_backend_ace` — the same "Hard" label should feel comparably hard on either backend, even
though the underlying math is completely different per backend.

> **Naming note** (TERMINOLOGY.md §2/§9): these five names are a gameplay-authoring difficulty
> scale, not the real T1–T4 military triage categories. Keep them visually/verbally distinct in UI
> copy — a scenario labelled "Hard" should never appear next to, or be confusable with, a patient
> labelled "T2." If a MASCAL sorting/triage exercise feature is ever built, it should use T1–T4
> directly rather than repurposing these labels.

---

## 5. Feature Breakdown

- **Selectable Body Limbs** — limb-diagram UI (native dialog, clickable silhouette regions) →
  emits `limb.selected` event on the bus.
- **Selectable Injuries** — per-limb injury editor (wound type, severity, bleed toggle, custom
  variables) → emits `injury.applied`/`injury.removed`.
- **Injury Presets** — built-in + user library, save/load/export/import, apply-to-selected-unit.
- **Injury Levels (Randomization)** — pick a level → domain logic rolls a concrete injury set from
  that level's profile → applies via the same `injury.applied` path presets use (one application
  pipeline, three sources: manual, preset, randomized).
- **Random Patient** — spawns a unit with a randomized identity/loadout *and* a randomized injury
  set (level-selectable) in one action — for quick drills.
- **Stretcher Placement** — selectable stretcher type (class list sourced from whichever backend
  is active, §2.5), ghost-preview placement (surface-snapped, like Zeus placement), spawns synced
  for MP.
- **Map to Spawn Patients** — map-click patient placement/preview, supports batch placement for
  MASCAL scenarios, respects the same spawn pipeline as Random Patient.

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
    ui/                # afcm_sim_ui — native dialogs + component kit + event bus, self-contained
                        # requiredAddons = {cba_main}
    scenario/          # afcm_sim_scenario — injury model, preset library, randomization profiles
                        # requiredAddons = {cba_main} — calls the backend interface only
    spawner/           # afcm_sim_spawner — patient spawner, stretcher placement, map tool
                        # requiredAddons = {cba_main} — calls the backend interface only
    backend_afcm/      # afcm_sim_backend_afcm — implements the interface against AFCM's PatientState API
                        # requiredAddons = {cba_main, afcm_main} — only loads if AFCM present
    backend_ace/       # afcm_sim_backend_ace — implements the interface against ace_medical_engine,
                        # with KAT/ACM-specific enhancements detected internally at postInit
                        # requiredAddons = {cba_main, ace_medical_engine} — only loads if ACE3 present
  docs/
    DESIGN.md          # this file
    PRESET_FORMAT.md   # (future) user preset export/import spec
```

Folder names on disk are bare (`ui`, `scenario`, ...) per standard HEMTT/ACE3-style convention —
HEMTT prepends the project prefix (`afcm_sim`) automatically to produce each PBO. The full
`afcm_sim_*` name is still each addon's `CfgPatches` class name and the name used everywhere else
in this doc (`requiredAddons`, prose) — only the physical folder differs from that name.

No changes required to Tasman-Dynamics-Core for this project. Neither backend addon requires the
other — see §2.5 for why that split makes AFCM (and ACE3/KAT/ACM) genuinely optional rather than
one hard-required with the other bolted on.

---

## 8. Open Questions (need your call before implementation starts)

1. **KAT internals** — do we vendor/checkout KAT source locally to confirm hitpoint names, wound
   classes, and treatment thresholds for `afcm_sim_backend_ace`, or reverse-engineer from the
   packed mod when that addon is actually scheduled?
2. **AFCM API surface** — this doc assumes AFCM will expose a stable `PatientState`-mutation API
   (per AFCM DESIGN.md §6); needs to be nailed down jointly with AFCM's own implementation order
   (its §9 roadmap) before `afcm_sim_backend_afcm` can be built — though per §9 below, this no
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

---

## 9. Phased Roadmap

- **v0.1 (this doc)** — design only.
- **v1 MVP** — native-dialog UI, the backend interface (§2.5) and its detection/selection logic,
  manual limb + injury selection, single-patient spawn (no map tool yet), SP + MP validated —
  shipped against **`afcm_sim_backend_ace` first**. ACE3 and KAT already exist today; AFCM does
  not yet (its own §9 shows physiology core landing in AFCM's v1, cardiac/defib in v2). Building
  the ACE backend first means AFCM-Simulator has a real, usable v1 without waiting on AFCM's build
  order at all — and proves the backend-interface abstraction (§2.5 open question #6) against a
  concrete, already-shipped mod before `afcm_sim_backend_afcm` has to conform to it.
- **v1.x** — `afcm_sim_backend_afcm` lands once AFCM's `PatientState` API (§8 open question #2) is
  stable enough to build against — likely tracking AFCM's own v1/v2, not gated on AFCM-Simulator's
  own version number.
- **v2** — injury presets (built-in + user save/load); randomization levels; Random Patient;
  stretcher placement — implemented once against the backend interface, so both backends get them
  simultaneously rather than one at a time.
- **v3** — map spawn tool, MASCAL batch placement, preset import/export/sharing.
- **Phase-2 spike (parallel, inside AFCM-Simulator)** — overlay-window proof of concept, evaluated
  independently; only promoted to "supported" if the hard problems in §2.3 are actually solved.

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
