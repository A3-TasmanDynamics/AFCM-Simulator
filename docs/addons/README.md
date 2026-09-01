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
| `main` | `afcm_sim_main` | `cba_main` | Owns the backend interface (`afcm_sim_fnc_backend_registerBackend`/`selectBackend`/`applyInjury`/`removeInjury`/`getState`/`reset`/`setUnconscious`/`getActive`) that every other addon calls through, plus the CBA Addon Options settings (`afcm_sim_debugLogging`, `afcm_sim_defaultInjuryLevel`, `afcm_sim_defaultCasualtyType`) and two real CBA keybinds (default Ctrl+Shift+M/Ctrl+Shift+O, `fnc_registerMciCreatorKeybind.sqf`/`fnc_registerSessionManagerKeybind.sqf`) that open the MCI Creator/Session Manager. Also sets the real ACE setting `ace_medical_spontaneousWakeUpChance` to 0 mission-wide (`fnc_disableSpontaneousWakeup.sqf` — see REFERENCES.md for why). The only addon every other AFCM-Simulator addon ultimately depends on |
| `ui` | `afcm_sim_ui` | `cba_main` | Dialog framework + event bus (`afcm_sim_ui_fnc_publish`/`subscribe`). Ten real dialogs, all true-centered on screen (except the near-fullscreen Map Picker): limb-select ("main" screen — button-per-limb, not a silhouette; buttons **toggle** on/off, real `ctrlSetBackgroundColor` recoloring, so more than one limb can be selected before an "Apply Trauma to Selected Limb(s)" button continues, plus Presets and full-patient Reset Patient buttons), the injury editor (wound type/severity/bleeding, applied identically to every selected limb in one Apply — `AFCM_SIM_UI_targetLimbs`, plural; Back returns to limb-select instead of closing outright; Save as Preset, one entry per selected limb; a purely-local, non-destructive Reset Limb; plus KAT-only Fracture/Pneumothorax controls shown only when KAT is active and at least one selected limb is an arm or a leg), the Preset Library (apply/delete/export/import — also has an MCI batch mode via `AFCM_SIM_UI_targetUnits`), a Preset Save name-prompt, the **MCI Creator** (`afcm_sim_ui_fnc_mciCreator_open` — standalone, per-patient independent presets, patient count 1-10, plus an optional Session Name text field that overrides the incident's auto-generated Spawn Session label), a real interactive **Map Picker** (genuine `RscMapControl`, `MouseButtonDown` + `ctrlMapScreenToWorld`, drops a real local marker at the pick via `createMarkerLocal`), an MCI Preset Library/Save pair (same shape as the single-injury ones, for whole incidents), the **Session Manager** (`afcm_sim_ui_fnc_sessionManager_open` — lists/deletes Spawn Sessions), and a generic reusable **Confirm dialog** (`afcm_sim_ui_fnc_confirmDialog_open` — Yes/No, any future destructive action can reuse it; currently gates the Session Manager's "Clear All Sessions"). Entry points are vanilla `addAction`s on spawned patients ("Edit Injuries" per patient, "Assign MCI Preset" on a whole freshly-spawned batch — `zeus`'s MCI Spawner module) plus the MCI Creator/Session Manager's own keybinds, not the ACE interaction menu |
| `scenario` | `afcm_sim_scenario` | `cba_main`, `afcm_sim_main` | Domain logic — `afcm_sim_scenario_fnc_randomizeInjuries` rolls a real `Injury` array from an injury-level profile ([DESIGN.md §4.4](../DESIGN.md#44-injury-levels-randomization-difficulty)); `serverApplyInjury`/`serverReset` are the server-authoritative request handlers the injury editor uses; `serverApplyKatFracture`/`serverApplyKatPneumothorax` are the same for KAT-only state (INJURY_CODES.md §6), guarding on KAT actually being the active backend before calling directly into `kat_compat`; `buildInjury` builds a real Injury HashMap from the 4 lightweight primitives (limb/woundType/severity/bleeding) every non-HashMap caller needs. Owns the Injury Preset library (INJURY_CODES.md §4) — `getBuiltinPresets`/`getUserPresets`/`saveUserPreset`/`deleteUserPreset`/`findPreset`/`exportPreset`/`importPreset`, plus `serverApplyPreset` (loops `serverApplyInjury` once per injury). Also owns a *second*, separate MCI preset library (same shape, `MciPresets` — `getBuiltinMciPresets`/`getUserMciPresets`/`saveUserMciPreset`/`deleteUserMciPreset`/`findMciPreset`/`exportMciPreset`/`importMciPreset`) plus `resolveMciPatientSpec` (turns one patient's spec — a Preset id, or `"random"` — into real Injuries) and `serverSpawnMci` (spawns a whole incident, one patient per spec, each independently resolved) |
| `spawner` | `afcm_sim_spawner` | `cba_main`, `afcm_sim_main`, `afcm_sim_scenario` | Patient spawning/clearing — `spawnPatient`, `spawnRandomPatient`, `clearAllPatients`. Owns `AFCM_SIM_patientGroup`/`AFCM_SIM_spawnedPatients`/`AFCM_SIM_spawnSessions`. Server-authoritative. `spawnPatient` knocks patients out via the `afcm_sim_fnc_backend_setUnconscious` op (`ace_medical_fnc_setUnconscious`, not the engine command — REFERENCES.md "Round 4", the confirmed root cause of "healing itself") and re-asserts it every 3s per patient for as long as it exists, as a safety net. Takes a Casualty Type arg (`C_man_1`/`B_Soldier_F`/`O_Soldier_F`/`I_Soldier_F` — all real, base-game classnames) and always strips the spawned unit to bare clothing (`removeAllWeapons`/`removeAllItems`/`removeAllAssignedItems`/`removeVest`/`removeBackpack`/`removeHeadgear`/`removeGoggles`) regardless of which one's picked. Also owns **Spawn Sessions** — every patient joins one (`newSessionId`, `[id, label, spawnTime, units]`), single spawns get their own automatically, batch spawners (MCI Spawner modules, MASCAL Zone, MCI Creator) share one per batch; `getSessions`/`serverDeleteSession` let just one session's patients be deleted (Session Manager UI) without touching any other session's |

## Backends

One PBO per medical mod, each gating on that mod's real `requiredAddons` so it only loads when its
target is actually present — the mechanism behind AFCM being a soft, not hard, dependency. See
[DESIGN.md §2.5](../DESIGN.md#25-soft-dependencies--runtime-backend-detection) for how registration/
selection/priority actually works across all four of these at once.

| Addon | PBO | `requiredAddons` | Priority | Status |
|---|---|---|---|---|
| `afcm_compat` | `afcm_sim_afcm_compat` | `afcm_main` | 20+ (planned) | Deferred, config-only stub — waiting on AFCM's `PatientState` API to stabilize |
| **[`kat_compat`](KAT_COMPAT.md)** | `afcm_sim_kat_compat` | `ace_medical_engine`, `kat_main` | 15 | **`applyInjury`/`getState` are real** — identical to `ace_compat`'s, since KAT extends ACE's own wound pipeline rather than replacing it. `removeInjury` is a stub. **`applyFracture`/`applyPneumothorax` are real too** — KAT-only state with no ACE equivalent, wired into the injury editor UI (KAT_COMPAT.md §2). **Full doc: [KAT_COMPAT.md](KAT_COMPAT.md)** |
| `acm_compat` | `afcm_sim_acm_compat` | `ace_medical_engine` | between ace/kat (planned) | Deferred stub — `requiredAddons` is still a placeholder identical to `ace_compat`'s, since ACM's real `CfgPatches` class name isn't confirmed |
| **[`ace_compat`](ACE_COMPAT.md)** | `afcm_sim_ace_compat` | `ace_medical_engine` | 10 | **`applyInjury` is real** (grounded directly in ACE3 source — `ace_medical_fnc_addDamageToUnit` + `ace_medical_fnc_addWound`). `removeInjury` is a stub. **Full doc: [ACE_COMPAT.md](ACE_COMPAT.md)** |

## Editor Integration

| Addon | PBO | `requiredAddons` | What it does |
|---|---|---|---|
| `zeus` | `afcm_sim_zeus` | `cba_main`, `afcm_sim_main`, `afcm_sim_scenario`, `afcm_sim_spawner` | Three Zeus modules. "Spawn Patient" (class still named `AFCM_SIM_ModuleSpawnRandomPatient` internally) — spawns clean/unconscious, injuries picked afterward via the "Edit Injuries" action, not randomized. "MCI Spawner" (`AFCM_SIM_ModuleMciSpawner`) — spawns a batch (Patient Count attribute) of clean patients, then adds an "Assign MCI Preset" action to the whole group; clicking it opens the real Preset Library in batch mode so one Apply gives every patient in the group the same exact preset. "Edit Injuries" (`AFCM_SIM_ModuleEditInjuries`, `curatorCanAttach = 1`) — drag it directly onto any unit (not just AFCM-spawned patients) to open the Injury Editor for it immediately, same real "drop onto a unit" mechanism as ACE3's own Zeus "Heal" module (target read via `attachedTo _logic`, dialog opened only on the placing curator's own machine via a `local _logic` guard, then self-deletes). Spawn Patient/MCI Spawner both have a "Casualty Type" attribute (Civilian/Military BLUFOR/OPFOR/Independent, `AFCM_SIM_CasualtyTypeAttributes`) for clothing/appearance only, plus an optional "Session Name" text attribute (same shared class) that overrides the batch's auto-generated Spawn Session label when non-blank. Category grouping via `CfgFactionClasses` + `side = 7`, not `CfgVehicleClasses` (Zeus-specific gotcha, not an Eden mechanism — see the modules' own `config.cpp` comments) |
| `eden` | `afcm_sim_eden` | `cba_main`, `afcm_sim_main`, `afcm_sim_scenario`, `afcm_sim_spawner` | Four Eden modules, all also `scopeCurator = 2` so they're Zeus-placeable too. "AFCM Patient" (spawns clean, same "Edit Injuries" flow as Zeus's Spawn Patient — no injury-level attribute anymore, but keeps a "Casualty Type" one). "AFCM MASCAL Zone" (patient-count + injury-level + casualty-type attributes, randomized by level — batch/mass-casualty drills where a specific injury set doesn't matter). "AFCM MCI Spawner" (`AFCM_SIM_ModuleMciSpawnerPlacement`, patient-count + casualty-type + a static Preset attribute — the 5 built-in presets only, since a design-time module can't reference a specific player's own future `profileNamespace` user presets) — every patient in the batch gets the exact same preset, spawned already-applied on mission start, no dialog needed. First three share the same optional "Session Name" text attribute as Zeus's modules. "Interactive Terminal" (`AFCM_SIM_ModuleInteractiveTerminal`, `curatorCanAttach = 1`) — sync it (or drag it onto an object in Zeus) to any placed object, e.g. a Laptop, and every player gets two real addActions on it, "AFCM: Open MCI Creator" / "AFCM: Open Session Manager", a diegetic way into the tool kit for a training scenario that doesn't need the CBA keybind or Zeus itself |

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
