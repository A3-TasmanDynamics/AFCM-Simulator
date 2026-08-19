<div align="center">

<img src="docs/assets/banner.svg" alt="AFCM-Simulator" width="100%"/>

[![License: APL-SA](https://img.shields.io/badge/license-APL--SA-b5563b)](https://www.bohemia.net/community/licenses/arma-public-license-share-alike)
[![Platform: Arma 3](https://img.shields.io/badge/platform-Arma%203-4b5d3a)](https://arma3.com/)
[![Requires AFCM](https://img.shields.io/badge/requires-AFCM-4b5d3a)](https://github.com/A3-TasmanDynamics/AFCM)
[![Status: Design Phase](https://img.shields.io/badge/status-design%20phase-8a7a3a)](docs/DESIGN.md)
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
| 🩸 **Selectable Injuries** | Wound type, severity, bleed state, and custom variables per limb |
| 📋 **Injury Presets** | Built-in (GSW, HE frag, blast lung) and user-saved, exportable/shareable presets |
| 🎲 **Injury Levels** | Five randomization profiles — Easy → Medium → Hard → Extreme → **F\*CKED!** |
| 🧑 **Random Patient** | One action: randomized identity, loadout, and injury set |
| 🛏️ **Stretcher Placement** | Selectable stretcher type, surface-snapped ghost-preview placement |
| 🗺️ **Map to Spawn Patients** | Click-to-place patients on the map, including MASCAL batch placement |

*Every path above funnels through one application pipeline — manual, preset, or randomized — so
presets and the randomizer produce exactly what a medic could also build by hand.*

## 🔗 How It Relates to AFCM

AFCM-Simulator is **standalone** — it doesn't depend on Tasman-Dynamics-Core, and owns its own
native-dialog UI kit rather than sharing one. It **does** depend on AFCM: every injury this tool
authors is applied through AFCM's own `PatientState` API as the primary path. [ACE3](https://github.com/acemod/ACE3),
[KAT - Advanced Medical](https://steamcommunity.com/workshop/filedetails/?id=2020940806), and
[ACM](https://steamcommunity.com/sharedfiles/filedetails/?id=3235483358) support exists only as an
isolated, optional compat bridge (`afcm_sim_compat`) for servers not running AFCM at all — see
[DESIGN.md](docs/DESIGN.md) for the full reasoning.

## 🧾 Requirements

| Dependency | Status |
|---|---|
| [AFCM](https://github.com/A3-TasmanDynamics/AFCM) | Required |
| [Community Base Addons (CBA_A3)](https://github.com/CBATeam/CBA_A3) | Required |
| [ACE3](https://github.com/acemod/ACE3) | Optional — `afcm_sim_compat` bridge only |
| [KAT - Advanced Medical](https://steamcommunity.com/workshop/filedetails/?id=2020940806) | Optional — `afcm_sim_compat` bridge only |
| [ACM (Advanced Combat Medicine)](https://steamcommunity.com/sharedfiles/filedetails/?id=3235483358) | Optional — `afcm_sim_compat` bridge only |

## 📚 Documentation

| Doc | What's in it |
|---|---|
| [DESIGN.md](docs/DESIGN.md) | UI architecture decision, data model, MP authority, repo layout, phased roadmap |
| [AFCM/TERMINOLOGY.md](https://github.com/A3-TasmanDynamics/AFCM/blob/main/docs/TERMINOLOGY.md) | Shared glossary — clinical, tactical-medicine, and radio-callings terminology |

## 🗺️ Status

**Design phase.** Planned build order (full detail in [DESIGN.md §9](docs/DESIGN.md#9-phased-roadmap)):

`v1` Native-dialog UI + manual limb/injury selection against AFCM's native API →
`v2` Presets + randomization levels + Random Patient + stretcher placement →
`v3` Map spawn tool + MASCAL batch placement + preset sharing

## 📜 License

Released under the [Arma Public License Share Alike (APL-SA)](https://www.bohemia.net/community/licenses/arma-public-license-share-alike).

---

<div align="center">

Part of the [AFCM](https://github.com/A3-TasmanDynamics/AFCM) project family. [Join the Tasman Dynamics Discord](https://discord.gg/Wt4ahmxVrs).

</div>
