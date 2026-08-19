# AFCM Medical Simulator — Design Doc

Status: **Draft v0.2** — pre-implementation. Nothing in this doc is committed to code yet.
Owner: Tasman Dynamics
Depends on: ACE3, KAT - Advanced Medical, CBA_A3

AFCM-Simulator is **standalone** — it does not depend on Tasman-Dynamics-Core. It owns its own UI
component kit rather than sharing one. See §2.4 and §3 for the reasoning.

---

## 1. Purpose & Scope

AFCM Medical Simulator is a scenario-building tool: instructors/medics configure a patient's
injuries (by limb, by type, by severity), spawn them into the world (individually or via preset,
individually or randomized), and treat them under ACE3 + KAT - Advanced Medical rules. It must
work identically in singleplayer, hosted MP, and dedicated server — same constraint set as every
other TasDyn framework (see `about.md`: deterministic, zero-compromise multiplayer sync).

Out of scope for v1: AI-driven patient behavior beyond what ACE3/KAT already provide, campaign/
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

---

## 3. System Layering

```
AFCM-Simulator (standalone addon)
   ├─ depends on ─→ ACE3 (ace_medical, ace_medical_engine, ace_interaction menu)
   ├─ depends on ─→ KAT - Advanced Medical (extended wound/treatment layer over ACE3 medical)
   └─ depends on ─→ CBA_A3
```

No Tasman-Dynamics-Core dependency. Everything AFCM needs — dialog framework, event bus, domain
logic — lives inside AFCM-Simulator's own addons (§7). The internal split still matters for
maintainability even without a separate repo:

- **`afcm_ui`** owns the **dialog framework** (native-dialog component kit: buttons, sliders,
  limb-diagram hit-areas, dropdowns, list boxes — styled once, reused across every AFCM screen) and
  the **event bus** used to decouple "UI raised an intent" from "domain logic executed it," so a
  Phase-2 overlay could later publish/subscribe to the same bus without a rewrite.
- **`afcm_medical` / `afcm_spawner` / `afcm_ace_kat_bridge`** own: the body/injury data model,
  injury presets, randomization profiles, patient spawner, stretcher placement, the map tool, and
  the ACE3/KAT adapter that translates AFCM's internal injury representation into actual
  `ace_medical_engine` hitpoint damage / KAT wound calls.

---

## 4. Data Model

### 4.1 Body limb selection
ACE3 medical's hitpoint set (which KAT extends rather than replaces) is the source of truth:

| AFCM limb id | ACE3 hitpoint(s) |
|---|---|
| `head` | `HitHead` |
| `torso` | `HitBody`, `HitNeck` (chest/neck grouped in UI, distinct hitpoints internally) |
| `armLeft` | `HitLeftArm` |
| `armRight` | `HitRightArm` |
| `legLeft` | `HitLeftLeg` |
| `legRight` | `HitRightLeg` |

> Needs verification once KAT's source is vendored/checked out locally — KAT is known to add
> finer-grained bleeding/tourniquet-per-limb tracking on top of ACE3's hitpoints; this table
> assumes it reuses ACE3's hitpoint names rather than introducing new ones. Flag as a spike task
> before §6.2 is implemented.

### 4.2 Injury object
```
Injury = {
    limb: LimbId,
    woundType: String,       // maps to ACE3 CfgWoundTypes / KAT's extended wound classes
    severity: 0.0..1.0,      // damage magnitude at time of application
    bleeding: Bool,
    bleedRate: Number,       // only relevant if bleeding = true
    tourniquetable: Bool,    // derived from limb, not authored per-injury
    variables: {}            // free-form key/value for custom presets (e.g. "fracture": true)
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

These ranges are a starting proposal, not tuned values — needs a pass with someone who knows KAT's
actual severity/treatment thresholds so "Hard" reliably feels harder in KAT's system, not just in
raw numbers.

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
- **Stretcher Placement** — selectable stretcher type (ACE3/KAT-compatible classes), ghost-preview
  placement (surface-snapped, like Zeus placement), spawns synced for MP.
- **Map to Spawn Patients** — map-click patient placement/preview, supports batch placement for
  MASCAL scenarios, respects the same spawn pipeline as Random Patient.

---

## 6. Multiplayer Architecture

Following the same principles as the rest of the TasDyn stack (`about.md` — deterministic, no
desync, validation on an authority machine):

- **Authority**: patient spawning, injury application, and preset resolution execute
  **server-side** (or the logical host in a non-dedicated game) as the single source of truth.
  Clients send *requests* (spawn patient X with preset Y / apply injury Z to unit U); the
  server validates and executes, then the resulting state (hitpoint damage, KAT wound state)
  propagates through ACE3/KAT's own existing sync (both already handle hitpoint/medical state
  replication) — AFCM does not need to invent its own damage-sync layer, only the
  request→authority→domain-call path for *AFCM-specific* actions (preset application, spawn
  placement) that ACE3/KAT don't know about.
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
    afcm_medical/            # domain logic: injury model, preset library, randomization profiles
    afcm_ui/                 # native dialogs + component kit + event bus, self-contained
    afcm_spawner/             # patient spawner, stretcher placement, map tool
    afcm_ace_kat_bridge/      # translates AFCM injuries → ace_medical_engine / KAT calls
  docs/
    DESIGN.md                 # this file
    PRESET_FORMAT.md          # (future) user preset export/import spec
```

No changes required to Tasman-Dynamics-Core for this project.

---

## 8. Open Questions (need your call before implementation starts)

1. **KAT internals** — do we vendor/checkout KAT source locally to confirm hitpoint names, wound
   classes, and treatment thresholds before locking §4.1/§4.4, or reverse-engineer from the packed
   mod in-session?
2. **Preset sharing format** — plain SQF-readable string blob (easy in-mission use, ugly to diff/
   share) vs. JSON file players place in a folder (needs a file-read approach compatible with
   dedicated servers)?
3. **MASCAL batch spawning scale** — what's the realistic max simultaneous patients (drives how
   much we need to worry about spawn-request throttling/authority queueing)?
4. **Phase-2 overlay spike** — worth timeboxing now as a small proof-of-concept (e.g. just get a
   transparent click-through window tracking the Arma window with one live-updating field from
   SQF), or defer until AFCM v1 native-dialog UI is feature-complete?

---

## 9. Phased Roadmap

- **v0.1 (this doc)** — design only.
- **v1 MVP** — native-dialog UI; manual limb + injury selection; ACE3/KAT bridge; single-patient
  spawn (no map tool yet); SP + MP validated.
- **v2** — injury presets (built-in + user save/load); randomization levels; Random Patient;
  stretcher placement.
- **v3** — map spawn tool, MASCAL batch placement, preset import/export/sharing.
- **Phase-2 spike (parallel, inside AFCM-Simulator)** — overlay-window proof of concept, evaluated
  independently; only promoted to "supported" if the hard problems in §2.3 are actually solved.
