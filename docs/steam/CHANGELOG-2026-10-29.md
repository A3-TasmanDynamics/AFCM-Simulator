<div align="center">

<img src="../assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../../README.md) · [Design](../DESIGN.md) · [References](../REFERENCES.md) · [Addons](../addons/README.md) · [Injury Codes](../INJURY_CODES.md) · [Field Manual](../FIELD_MANUAL.md) · [Steam Description](../STEAM_DESCRIPTION.md) · [Changelog](../changelogs/README.md) · **Steam Changelog**

</div>

# Steam Workshop Change Note (2026-10-29)

**Note on format**: same convention as `docs/STEAM_DESCRIPTION.md` — Steam's own BBCode tags, not
Markdown. Copy everything inside the fence below and paste it directly into the Workshop item's
**Change Note** field when publishing this update.

---

```text
[b]Added[/b]
[list]
[*] Mark as Treated / Export Patient State can now be toggled off in Addon Options, and respect the Require Injury Edit Permission setting
[*] Injury Author: settable Pain Level, an Advanced Adjustments section, and mouseover tooltips
[*] Injury Author: consciousness is now a checkbox, staged until Apply — no longer forces the patient's state the moment you tick it
[*] Injury Author's live status readout redesigned — clearer, color-coded, no longer overflows
[*] Double-click a preset to apply/assign it instantly (MCI Creator, Preset Library)
[*] Wound types cleaned up to the exact real injury classes — Abrasion, Avulsion, Contusion, Crush, Cut, Laceration, Puncture Wound, Thermal Burn, Velocity Wound
[*] Zeus module icons — each module now has its own distinct icon
[*] MCI spawning now supports a configurable spawn radius with a live circle preview on the map, settable from the MCI Creator or the map picker — patients scatter realistically instead of stacking
[*] Zeus MCI Spawner: radius settable on the module's own attributes, with the location marker pre-placed on the map
[*] Zeus Spawn Patient module now opens the Injury Author automatically after spawning, and cleans up its own icon once placed
[*] Zeus Interactive Terminal now requires being placed on an object, and disappears once set up
[*] Random Damage renamed "Apply Random Damage" — applies immediately and closes the dialog
[/list]

[b]Changed/Fixed[/b]
[list]
[*] Fixed a crash when placing an AFCM Patient module or reloading a saved session in the editor
[*] Fixed the Injury Author navbar incorrectly highlighting adjacent limb buttons
[*] Clear All removed — Reset Patient now reliably clears everything, including unapplied random damage rolls
[*] Apply now closes the Injury Author dialog once it's done
[*] Preset Library / MCI Preset Library: Import/Apply and Import/Load button positions swapped
[/list]
```
