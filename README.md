<div align="center">

<img src="docs/assets/banner.svg" alt="AFCM-Simulator" width="100%"/>

[![License: APL-SA](https://img.shields.io/badge/license-APL--SA-b5563b)](https://www.bohemia.net/community/licenses/arma-public-license-share-alike)
[![Platform: Arma 3](https://img.shields.io/badge/platform-Arma%203-4b5d3a)](https://arma3.com/)
[![Backend: AFCM or ACE3/KAT/ACM](https://img.shields.io/badge/backend-AFCM%20or%20ACE3%2FKAT%2FACM-4b5d3a)](https://github.com/A3-TasmanDynamics/AFCM)
[![Status: Active Development](https://img.shields.io/badge/status-active%20development-8a7a3a)](docs/changelogs/v0.1.0.md)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?logo=discord&logoColor=white)](https://discord.gg/Wt4ahmxVrs)

</div>

---

**A Tasman Dynamics High-Fidelity Simulation Project**

AFCM-Simulator is the scenario-authoring and training companion for [AFCM](https://github.com/A3-TasmanDynamics/AFCM)
(Australian First Combat Medicine). Where AFCM is the physiology engine, AFCM-Simulator is the
tool instructors and mission makers use to actually put it to work: build a casualty, spawn it
into the world, and run a scenario against it — one patient at a time or a full mass-casualty
drill.

---

## 🩹 What It Does

| Feature | What it means |
|---|---|
| 🧍 **Selectable Body Limbs** | Clickable limb diagram to target where a casualty is hurt |
| 🩸 **Selectable Injuries** | Wound type, severity, bleed state per limb — plus KAT-only Fracture/Pneumothorax when KAT's the active backend |
| 📋 **Injury Presets** | Built-in (GSW, HE frag, blast lung) and user-saved, exportable/shareable presets — single-injury and whole-incident (MCI) |
| 🎲 **Injury Levels** | Five randomization profiles — Easy → Medium → Hard → Extreme → **F\*CKED!** |
| 🧑 **Casualty Type** | Civilian / Military BLUFOR / OPFOR / Independent — clothing and appearance on every spawn path |
| 🗺️ **MCI Creator** | Standalone tool: build an incident patient-by-patient, click a real interactive map for the spot, spawn it all at once |
| 🏥 **MCI Spawner & MASCAL Zone** | Zeus/Eden modules — spawn a whole batch on the spot, one shared preset or randomized by Injury Level |
| 🗂️ **Spawn Sessions** | Every batch is a named, independently-deletable session — two medics can each run their own MCI without clearing the other's |
| 🖱️ **Zeus Edit Injuries** | Drag a module directly onto any unit to open the Injury Editor immediately, no scroll action needed |
| 💻 **Interactive Terminal** | Sync a module to any placed object (a laptop, a table) for a diegetic way into the MCI Creator/Session Manager |
| ⛺ **Medical Tent** | Session-scoped treatment detection against your own composition's stretchers — notifies when an incident's fully treated |

*Every path above funnels through one application pipeline — manual, preset, or randomized — so
presets and the randomizer produce exactly what a medic could also build by hand.*

## 🔗 How It Relates to AFCM

AFCM-Simulator is **standalone** — it doesn't depend on Tasman-Dynamics-Core, and owns its own
native-dialog UI kit rather than sharing one. AFCM itself is a **soft dependency**: if it's
loaded, AFCM-Simulator uses its native `PatientState` API. If it's not, and
[ACE3](https://github.com/acemod/ACE3) (optionally with
[KAT - Advanced Medical](https://steamcommunity.com/workshop/filedetails/?id=2020940806) or
[ACM](https://steamcommunity.com/sharedfiles/filedetails/?id=3235483358)) is loaded instead,
AFCM-Simulator runs against that. Both are genuinely optional Workshop dependencies — pick either,
or run both and AFCM wins. See [DESIGN.md §2.5](docs/DESIGN.md#25-soft-dependencies--runtime-backend-detection)
for how the detection actually works.

## 🧾 Requirements

| Dependency | Status |
|---|---|
| [Community Base Addons (CBA_A3)](https://github.com/CBATeam/CBA_A3) | Required |
| [AFCM](https://github.com/A3-TasmanDynamics/AFCM) | Soft — enables the native physiology backend |
| [ACE3](https://github.com/acemod/ACE3) | Soft — required for the compat backend |
| [KAT - Advanced Medical](https://steamcommunity.com/workshop/filedetails/?id=2020940806) | Soft — its own backend (confirmed, outranks vanilla ACE3) if present alongside ACE3 |
| [ACM (Advanced Combat Medicine)](https://steamcommunity.com/sharedfiles/filedetails/?id=3235483358) | Soft — alternative backend alongside ACE3 (target not yet confirmed) |

> **At least one medical backend must be present** — AFCM, or ACE3 (optionally with KAT/ACM) — or
> AFCM-Simulator has nothing to apply injuries to. Run with just ACE3 + KAT and skip AFCM entirely
> if that's all you want; AFCM-Simulator detects what's actually loaded at mission start and picks
> the best available backend automatically (AFCM native path preferred when present). See
> [DESIGN.md §2.5](docs/DESIGN.md#25-soft-dependencies--runtime-backend-detection) for how.

## 📚 Documentation

| Doc | What's in it |
|---|---|
| [DESIGN.md](docs/DESIGN.md) | UI architecture decision, data model, MP authority, repo layout, phased roadmap |
| [REFERENCES.md](docs/REFERENCES.md) | ACE3 medical framework/function sources grounding `afcm_sim_ace_compat`'s implementation |
| [docs/addons/](docs/addons/README.md) | Per-addon index — one deep-dive doc per PBO: [ACE_COMPAT.md](docs/addons/ACE_COMPAT.md) for `afcm_sim_ace_compat`, [KAT_COMPAT.md](docs/addons/KAT_COMPAT.md) for `afcm_sim_kat_compat` |
| [INJURY_CODES.md](docs/INJURY_CODES.md) | The full injury coding reference — body parts, wound types, severity/bleeding coding, real ACE3 wound classes, and per-backend implementation status in one place |
| [docs/changelogs/](docs/changelogs/README.md) | One file per version, sourced straight from git history — [v0.1.0](docs/changelogs/v0.1.0.md) covers everything to date |
| [AFCM/TERMINOLOGY.md](https://github.com/A3-TasmanDynamics/AFCM/blob/main/docs/TERMINOLOGY.md) | Shared glossary — clinical, tactical-medicine, and radio-callings terminology |

## 🗺️ Status

**Active development — v0.1.0, no tagged release yet.** The core loop (spawn a patient, select or
randomize injuries, apply them against whichever backend is active) is real and working, along
with everything listed in *What It Does* above. Full, dated history:
[docs/changelogs/v0.1.0.md](docs/changelogs/v0.1.0.md). Longer-range plan:
[DESIGN.md §9 Phased Roadmap](docs/DESIGN.md#9-phased-roadmap).

## 🤝 Contributing

Changes land via feature branches and pull requests, not direct pushes to `main`:

1. Branch off `main` — `git checkout -b <type>/<short-description>` (`feat/…`, `fix/…`, `docs/…`,
   `chore/…`)
2. Commit there, push the branch, open a PR against `main`
3. Review and merge happens on the PR, not as a local merge

## 📜 License

Released under the [Arma Public License Share Alike (APL-SA)](https://www.bohemia.net/community/licenses/arma-public-license-share-alike).

---

<div align="center">

Part of the [AFCM](https://github.com/A3-TasmanDynamics/AFCM) project family. [Join the Tasman Dynamics Discord](https://discord.gg/Wt4ahmxVrs).

</div>
