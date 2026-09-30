<div align="center">

<img src="assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../README.md) · [Design](DESIGN.md) · [References](REFERENCES.md) · [Addons](addons/README.md) · [Injury Codes](INJURY_CODES.md) · **Field Manual** · [Changelog](changelogs/README.md)

</div>

# Field Manual — How to Use AFCM-Simulator

**Tasman Dynamics** — a step-by-step usage guide: spawn a patient, configure exactly what's wrong
with them, run the scenario. This is the plain-text reference; there's also an
[illustrated version](https://claude.ai/artifact/CXKo5fhfGCsHtowfe8dmSt) with diagrams if you'd
rather read it that way. Both cover the same ground.

---

## 1. Before You Start

| Component | Status | Why you need it |
|---|---|---|
| [Community Base Addons (CBA_A3)](https://github.com/CBATeam/CBA_A3) | Required | Every setting, keybind and menu in this mod runs through it |
| [AFCM](https://github.com/A3-TasmanDynamics/AFCM) | Soft | Native physiology backend — preferred automatically when loaded |
| [ACE3](https://github.com/acemod/ACE3) | Soft | Alternative backend, used if AFCM isn't present |
| [KAT – Advanced Medical](https://steamcommunity.com/workshop/filedetails/?id=2020940806) | Soft, with ACE3 | Unlocks Fracture / Pneumothorax / Airway / Cardiac controls |
| [ACM](https://steamcommunity.com/sharedfiles/filedetails/?id=3235483358) | Soft, with ACE3 | Alternative advanced backend alongside ACE3 |

> **At least one backend is mandatory.** AFCM, or ACE3 (optionally with KAT/ACM) — without one of
> the two, there's nothing for this mod to apply an injury to. Detection is automatic at mission
> start; AFCM wins if both are present.

## 2. How It Works — One Pipeline, Three Sources

Every casualty starts the same way: clean and unconscious. What happens to them next always goes
through the same single step, no matter which of three ways you chose to decide it:

```
   Manual              Preset            Randomized
(Injury Author)    (built-in/saved)   (Injury Level roll)
        \                 |                 /
         \                |                /
          \----------- APPLY INJURY ------/
                          |
                    backend: AFCM or ACE3 (+KAT)
                          |
                       Patient
```

A preset or a random roll never produces anything you couldn't also build by hand — they all
collapse into the exact same apply step.

## 3. Placing a Patient

Four ways to get a casualty into the world — pick whichever fits the moment.

### 3.1 — In Zeus (live)

- **Spawn Patient** module — drop it, get one clean, unconscious casualty on the spot. Scroll to
  **Edit Injuries** on them to configure what's wrong.
- **MCI Spawner** module — set **Patient Count** (2 / 4 / 6 / 8 / 10) and **Casualty Type**, drop
  it, and a scattered batch of unconscious patients appears. Scroll to **Assign MCI Preset** on any
  one of them to apply one preset to the whole batch at once.
- **Edit Injuries** module — drag it directly onto *any* unit to jump straight into that unit's
  Injury Editor. No scroll action needs to exist on the target first.

### 3.2 — In Eden (pre-authoring)

Place the **AFCM Patient** module for the design-time way to configure a casualty before the
mission ever starts. Its attributes:

| Attribute | What it does |
|---|---|
| Casualty Type | Civilian / BLUFOR / OPFOR / Independent — clothing/appearance only |
| Session Name (optional) | Label shown in the Session Manager |
| Title (editor-only) | Tells placed modules apart in Eden; also what a synced object's interaction reads out (below) |
| Training Preset (quick pick) | Quick-picks a built-in scenario (§5) instead of pasting an export string below — wins over Injury Preset unless left on "None" |
| Injury Preset (paste to import) | Paste an exported preset/patient-state string to spawn pre-configured |
| Spawn Marker Name(s) | Comma-separated exact placed-marker names (`Patient_1, Patient_2, Patient_3`) — one patient spawns at each marker that resolves. Blank = spawn at the module's own position |

**Title never renames the patient** — patients always get a random name. It's a label only.

**Sync an object to switch modes.** Ctrl+click-drag a sync line from the module to any placed
object (a laptop, a table) and it stops auto-spawning at mission start. Instead that object gets a
repeatable `"AFCM: Spawn <Title>"` interaction (or `"AFCM: Spawn Patient"` with no Title set) that
any player can use, on demand, as many times as the scenario needs.

### 3.3 — Interactive Terminal

Sync it (Eden) or drag it directly onto an object (Zeus) and every player gets two actions on that
object: `"AFCM: Open MCI Creator"` and `"AFCM: Open Session Manager"` — a diegetic way to hand the
whole authoring toolkit to a player without teaching them a keybind.

### 3.4 — From anywhere (keybinds)

No module needed. All three are rebindable in *Configure > Controls > Addon Bindings*.

| Keybind | Opens |
|---|---|
| `Ctrl` + `Shift` + `I` | Injury Author — build one custom patient from scratch |
| `Ctrl` + `Shift` + `M` | MCI Creator — build a full incident, patient by patient |
| `Ctrl` + `Shift` + `O` | Session Manager — view or clear active spawn sessions |

## 4. The Injury Author

Reached via a patient's **Edit Injuries** scroll action, the Zeus **Edit Injuries** module, or
`Ctrl`+`Shift`+`I` to author one with no unit yet.

Toggle one or more of the six body regions (`head`, `chest`, `leftArm`, `rightArm`, `leftLeg`,
`rightLeg`), then **Apply Trauma to Selected** — one wound configuration applies to every region
you toggled, in a single pass. Then configure the wound:

| Field | Options |
|---|---|
| Wound Type | None, Gunshot, Shrapnel, Blast |
| Severity | Light, Moderate, Severe, Critical |
| Bleeding | None, Small, Medium, Large |

A live status readout runs alongside — consciousness, pain, blood volume, and (with KAT active)
internal bleeding rate — updating while you work, not just after Apply.

> **KAT – Advanced Medical active?** Extra controls appear where they're relevant: **Fracture**
> (arm/leg limbs), **Pneumothorax** (chest), **Airway** Obstruction/Occlusion (head), **Cardiac
> State** (chest).

- **Apply** commits the whole selection in one click.
- **Reset Limb** clears just the form on screen; **Reset Patient** (one screen up) wipes everything
  done to that patient so far and re-locks them unconscious.
- **Save as Preset** turns whatever's configured into a reusable Preset (§5).
- Every spawned patient also carries an **"AFCM: Export Patient State"** action — copies their
  exact current injuries to your clipboard, ready to paste into an AFCM Patient module's Injury
  Preset field or the Preset Library's Import box.

## 5. Presets & Injury Levels

Two shortcuts into the same Apply step as §4 — neither does anything you couldn't also build by
hand.

**Presets** — a named, saved wound (or set of wounds). Eight ship built-in, plus whatever you save
yourself: GSW — Chest, GSW — Limb (Tourniquet Candidate), Blast Casualty, Frag Wounds (Multiple),
Training — Minor Laceration, Airway — Obstruction, Fractures — Multiple Limb, Severe Hemorrhage
(Multi-Site). Export/Import round-trip through your OS clipboard as plain text, so presets are easy
to hand to another mission maker.

**Injury Levels** — five randomization profiles, roll one instead of picking a wound by hand:
`Easy` → `Medium` → `Hard` → `Extreme` → `F*CKED!`

## 6. Mass-Casualty Incidents — MCI Creator

For when patients in the same incident need genuinely *different* injuries from each other — a
module MCI Spawner (§3.1) gives everyone the same preset; this doesn't have to. Open it with
`Ctrl`+`Shift`+`M`, or a synced Interactive Terminal's own action.

1. Set **Patient Count** (1–10).
2. Assign a Preset to each patient individually — or leave any of them on **Random**.
3. Click the real in-game map to place the incident exactly where you want it.
4. Set **Casualty Type** and an optional **Session Name**.
5. **Spawn MCI.**

Save the whole incident — patient count and who's got what — as an **MCI Preset** for reuse. Three
ship built-in: *HE Shell — 3 Casualties*, *IED Strike — 4 Casualties*, *Ambush — 2 Casualties*.

## 7. Sessions

Every batch spawned together — an MCI, a module's patients — is one named **Spawn Session**,
tracked independently of every other one. Two medics can each run their own incident at once
without clearing each other's patients.

Open the **Session Manager** with `Ctrl`+`Shift`+`O`, or the MCI Creator's own "Manage Sessions"
button. It lists every active session with a patient count and how long ago it spawned, and deletes
one at a time.

> **Clear All Sessions** wipes every patient from every session at once — the single destructive
> action in this whole toolkit, which is why it's the only one gated behind a Yes/No confirmation.

## 8. Settings — *Configure > Addon Options > AFCM Medical Simulator*

| Setting | Default | What it does |
|---|---|---|
| Default Injury Level | Medium | Pre-selected randomization level in the Injury Author |
| Default Casualty Type | Civilian | Fallback clothing when a placed module doesn't set its own |
| Remember Last-Used Injuries | Off | Auto-restores your last injuries when authoring a new patient (`Ctrl`+`Shift`+`I`) |
| Patient Terminal Interaction Method | Scroll Wheel | Scroll Wheel / ACE Interaction Menu / Both, for a synced AFCM Patient's on-demand spawn |
| Debug Logging | Off | Verbose diag_log output — leave off unless troubleshooting |

ACE Interaction Menu falls back to Scroll Wheel automatically on any client without ACE's
interaction menu loaded — nobody is ever left with no way to trigger a spawn.

## 9. Quick Reference

| Keybind | Opens |
|---|---|
| `Ctrl`+`Shift`+`I` | Injury Author |
| `Ctrl`+`Shift`+`M` | MCI Creator |
| `Ctrl`+`Shift`+`O` | Session Manager |

| Scroll action | Where it appears |
|---|---|
| Edit Injuries | Any spawned patient |
| AFCM: Export Patient State | Any spawned patient |
| Assign MCI Preset | Any patient in a Zeus MCI Spawner batch |
| AFCM: Spawn `<Title>` | An object synced to an on-demand AFCM Patient module |
| AFCM: Open MCI Creator / Open Session Manager | An Interactive Terminal object |

---

<div align="center">

Part of the [AFCM](https://github.com/A3-TasmanDynamics/AFCM) project family. [Join the Tasman Dynamics Discord](https://discord.gg/Wt4ahmxVrs).

</div>
