<div align="center">

<img src="../assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../../README.md) · [Design](../DESIGN.md) · [References](../REFERENCES.md) · **Addons Index** · [Injury Codes](../INJURY_CODES.md)

</div>

# Addon Index

**Tasman Dynamics** — one deep-dive doc per PBO. Start with [DESIGN.md](../DESIGN.md) for the
overall architecture (backend selection, data model, MP authority); this index is for "what does
*this specific addon* do" once you're already inside the codebase.

Ten addons ship in `AFCM-Simulator.pbo`'s parent mod, one folder each under `addons/`. Each row
below is real — pulled from each addon's own `config.cpp`, not aspirational.

## Core

| Addon | PBO | `requiredAddons` | What it does |
|---|---|---|---|
| `main` | `afcm_sim_main` | `cba_main` | Owns the backend interface (`afcm_sim_fnc_backend_registerBackend`/`selectBackend`/`applyInjury`/`removeInjury`/`getState`/`reset`/`getActive`) that every other addon calls through, plus the CBA Addon Options settings (`afcm_sim_debugLogging`, `afcm_sim_defaultInjuryLevel`). Also sets the real ACE setting `ace_medical_spontaneousWakeUpChance` to 0 mission-wide (`fnc_disableSpontaneousWakeup.sqf` — see REFERENCES.md for why). The only addon every other AFCM-Simulator addon ultimately depends on |
| `ui` | `afcm_sim_ui` | `cba_main` | Dialog framework + event bus (`afcm_sim_ui_fnc_publish`/`subscribe`). Two real dialogs: limb-select (button-per-limb, not a silhouette) and the backend-aware injury editor (wound type/severity/bleeding for ACE/KAT; real Fracture/Pneumothorax controls shown only for KAT; Apply disabled with an explanation if no usable backend is active) it opens next. Entry point is a vanilla `addAction` on spawned patients, not the ACE interaction menu |
| `scenario` | `afcm_sim_scenario` | `cba_main`, `afcm_sim_main` | Domain logic — currently `afcm_sim_scenario_fnc_randomizeInjuries`, which rolls a real `Injury` array from an injury-level profile ([DESIGN.md §4.4](../DESIGN.md#44-injury-levels-randomization-difficulty)) |
| `spawner` | `afcm_sim_spawner` | `cba_main`, `afcm_sim_main`, `afcm_sim_scenario` | Patient spawning/clearing — `spawnPatient`, `spawnRandomPatient`, `clearAllPatients`. Owns `AFCM_SIM_patientGroup`/`AFCM_SIM_spawnedPatients`. Server-authoritative |

## Backends

One PBO per medical mod, each gating on that mod's real `requiredAddons` so it only loads when its
target is actually present — the mechanism behind AFCM being a soft, not hard, dependency. See
[DESIGN.md §2.5](../DESIGN.md#25-soft-dependencies--runtime-backend-detection) for how registration/
selection/priority actually works across all four of these at once.

| Addon | PBO | `requiredAddons` | Priority | Status |
|---|---|---|---|---|
| `afcm_compat` | `afcm_sim_afcm_compat` | `afcm_main` | 20+ (planned) | Deferred, config-only stub — waiting on AFCM's `PatientState` API to stabilize |
| **[`kat_compat`](KAT_COMPAT.md)** | `afcm_sim_kat_compat` | `ace_medical_engine`, `kat_main` | 15 | **`applyInjury`/`getState` are real** — identical to `ace_compat`'s, since KAT extends ACE's own wound pipeline rather than replacing it. Also has two KAT-only real functions no ACE backend has: `applyFracture`/`applyPneumothorax`. `removeInjury` is a stub. **Full doc: [KAT_COMPAT.md](KAT_COMPAT.md)** |
| `acm_compat` | `afcm_sim_acm_compat` | `ace_medical_engine` | between ace/kat (planned) | Deferred stub — `requiredAddons` is still a placeholder identical to `ace_compat`'s, since ACM's real `CfgPatches` class name isn't confirmed |
| **[`ace_compat`](ACE_COMPAT.md)** | `afcm_sim_ace_compat` | `ace_medical_engine` | 10 | **`applyInjury` is real** (grounded directly in ACE3 source — `ace_medical_fnc_addDamageToUnit` + `ace_medical_fnc_addWound`). `removeInjury` is a stub. **Full doc: [ACE_COMPAT.md](ACE_COMPAT.md)** |

## Editor Integration

| Addon | PBO | `requiredAddons` | What it does |
|---|---|---|---|
| `zeus` | `afcm_sim_zeus` | `cba_main`, `afcm_sim_main`, `afcm_sim_scenario`, `afcm_sim_spawner` | "Spawn Patient" Zeus module (class still named `AFCM_SIM_ModuleSpawnRandomPatient` internally) — spawns clean/unconscious, injuries picked afterward via the "Edit Injuries" action, not randomized. Category grouping via `CfgFactionClasses` + `side = 7`, not `CfgVehicleClasses` (Zeus-specific gotcha, not an Eden mechanism — see the module's own `config.cpp` comments) |
| `eden` | `afcm_sim_eden` | `cba_main`, `afcm_sim_main`, `afcm_sim_scenario`, `afcm_sim_spawner` | "AFCM Patient" (spawns clean, same "Edit Injuries" flow as Zeus's Spawn Patient — no injury-level attribute anymore) and "AFCM MASCAL Zone" (patient-count + injury-level attributes, still randomized — batch/mass-casualty drills are the one place that still makes sense) Eden modules. Both also set `scopeCurator = 2` so they're Zeus-placeable too |

---

## Per-Addon Docs

Not every addon has its own deep-dive doc yet — only the ones complex enough to need one beyond
what's already in [DESIGN.md](../DESIGN.md) get a dedicated page here.

| Doc | Covers |
|---|---|
| [ACE_COMPAT.md](ACE_COMPAT.md) | `afcm_sim_ace_compat` — full function reference, `LimbId`/`woundType` mapping tables, and why injury application needs two ACE3 calls, not one |
| [KAT_COMPAT.md](KAT_COMPAT.md) | `afcm_sim_kat_compat` — real KAT/KAM sources, confirmed KAT-specific variables, and the finding that KAT extends ACE3's own wound pipeline instead of replacing it |

---

<div align="center">

**Tasman Dynamics** — Engineering high-fidelity systems for the future of multi-domain simulation.
[Discord](https://discord.gg/Wt4ahmxVrs) · [AFCM](https://github.com/A3-TasmanDynamics/AFCM)

</div>
