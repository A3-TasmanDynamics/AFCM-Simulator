<div align="center">

<img src="assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../README.md) · [Design](DESIGN.md) · [References](REFERENCES.md) · [Addons](addons/README.md) · [Injury Codes](INJURY_CODES.md) · [Field Manual](FIELD_MANUAL.md) · **Steam Description** · [Changelog](changelogs/README.md)

</div>

# Steam Workshop Page Description

**Note on format**: Steam Workshop description fields don't actually use Markdown — they use
Steam's own BBCode-style tags (`[h1]`, `[b]`, `[list]`, `[url=...]`, etc.), which is what's written
inside the code block below. Copy everything inside the fence and paste it directly into the
Workshop item's description field; Steam renders the tags itself. This file lives in `docs/` in
Markdown (`.md`) purely so it's tracked and diffable in git — GitHub won't render the tags, that's
expected.

To update the live listing after editing this file: paste the new content into the Workshop item's
**Change Note** / description editor on the Steam Workshop page and republish.

---

```text
[h1]AFCM-Simulator[/h1]
[i]A Tasman Dynamics High-Fidelity Simulation Project[/i]

[b]AFCM-Simulator[/b] is the scenario-authoring and training companion for [url=https://github.com/A3-TasmanDynamics/AFCM]AFCM (Australian First Combat Medicine)[/url]. Where AFCM is the physiology engine, AFCM-Simulator is the tool instructors and mission makers use to actually put it to work: build a casualty, spawn it into the world, and run a scenario against it — one patient at a time, or a full mass-casualty drill.

[hr][/hr]

[h2]What It Does[/h2]
[list]
[*] [b]Selectable Body Limbs[/b] — clickable limb diagram to target exactly where a casualty is hurt
[*] [b]Selectable Injuries[/b] — wound type, severity, and bleed state per limb, plus KAT-only Fracture / Pneumothorax / Airway / Cardiac State controls when KAT is the active backend
[*] [b]Injury Presets[/b] — 8 built-in (GSW, blast, frag, airway obstruction, multi-limb fracture, severe hemorrhage...) plus your own saved, exportable/shareable presets
[*] [b]Injury Levels[/b] — five randomization profiles: Easy → Medium → Hard → Extreme → F*CKED!
[*] [b]Casualty Type[/b] — Civilian / Military BLUFOR / OPFOR / Independent appearance on every spawn path
[*] [b]MCI Creator[/b] — build a mass-casualty incident patient-by-patient on a real interactive map, spawn it all at once
[*] [b]MCI Spawner[/b] — Zeus module: spawn a whole batch on the spot with one shared preset or randomized injuries
[*] [b]Spawn Sessions[/b] — every batch is a named, independently-deletable session, so two medics can each run their own incident without clearing the other's
[*] [b]Zeus Edit Injuries[/b] — drag a module directly onto any unit to open the Injury Editor immediately, no scroll action needed
[*] [b]Interactive Terminal[/b] — sync to any placed object (a laptop, a table) for a diegetic way into the MCI Creator / Session Manager
[/list]

[h2]How It Relates to AFCM[/h2]
AFCM-Simulator is standalone and owns its own native-dialog UI. AFCM itself is a soft dependency: if it's loaded, AFCM-Simulator uses its native PatientState API. If it's not, and ACE3 (optionally with KAT - Advanced Medical or ACM) is loaded instead, AFCM-Simulator runs against that. Both are genuinely optional — pick either, or run both and AFCM wins.

[h2]Requirements[/h2]
[list]
[*] [url=https://github.com/CBATeam/CBA_A3]CBA_A3[/url] — [b]required[/b]
[*] [url=https://github.com/A3-TasmanDynamics/AFCM]AFCM[/url] — soft, enables the native physiology backend
[*] [url=https://github.com/acemod/ACE3]ACE3[/url] — soft, required for the compat backend
[*] [url=https://steamcommunity.com/workshop/filedetails/?id=2020940806]KAT - Advanced Medical[/url] — soft, alongside ACE3
[*] [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3235483358]ACM (Advanced Combat Medicine)[/url] — soft, alongside ACE3
[/list]
[b]At least one medical backend must be present[/b] — AFCM, or ACE3 (optionally with KAT/ACM) — or AFCM-Simulator has nothing to apply injuries to. It detects what's loaded automatically and picks the best available backend.

[h2]Getting Started[/h2]
Full step-by-step field manual: [url=https://github.com/A3-TasmanDynamics/AFCM-Simulator/blob/main/docs/FIELD_MANUAL.md]on GitHub[/url], or the [url=https://claude.ai/artifact/CXKo5fhfGCsHtowfe8dmSt]illustrated version[/url]. Quick start:
[list]
[*] In Zeus: place [b]Spawn Patient[/b] or [b]MCI Spawner[/b], then scroll to [b]Edit Injuries[/b] on the patient
[*] In Eden: place [b]AFCM Patient[/b], pick a Training Preset or paste an exported one
[*] Anywhere: [b]Ctrl+Shift+I[/b] opens the Injury Author, [b]Ctrl+Shift+M[/b] opens the MCI Creator
[/list]

[h2]Status[/h2]
Active development — v0.1.0. The core loop (spawn a patient, select or randomize injuries, apply them against whichever backend is active) is real and working. Full changelog [url=https://github.com/A3-TasmanDynamics/AFCM-Simulator/blob/main/docs/changelogs/v0.1.0.md]here[/url].

[h2]Links[/h2]
[list]
[*] [url=https://github.com/A3-TasmanDynamics/AFCM-Simulator]Source & Documentation[/url]
[*] [url=https://discord.gg/Wt4ahmxVrs]Discord[/url]
[*] [url=https://www.bohemia.net/community/licenses/arma-public-license-share-alike]License: Arma Public License Share Alike (APL-SA)[/url]
[/list]

[i]Part of the AFCM project family.[/i]
```
