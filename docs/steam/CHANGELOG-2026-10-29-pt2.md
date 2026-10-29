<div align="center">

<img src="../assets/doc-header.svg" alt="AFCM-Simulator Documentation" width="100%"/>

[README](../../README.md) · [Design](../DESIGN.md) · [References](../REFERENCES.md) · [Addons](../addons/README.md) · [Injury Codes](../INJURY_CODES.md) · [Field Manual](../FIELD_MANUAL.md) · [Steam Description](../STEAM_DESCRIPTION.md) · [Changelog](../changelogs/README.md) · **Steam Changelog**

</div>

# Steam Workshop Change Note (2026-10-29, part 2)

**Note on format**: same convention as `docs/STEAM_DESCRIPTION.md` — Steam's own BBCode tags, not
Markdown. Copy everything inside the fence below and paste it directly into the Workshop item's
**Change Note** field when publishing this update.

---

```text
[b]Added[/b]
[list]
[*] Zeus Spawn Patient module now opens a picker to choose Casualty Type before anything spawns, and remembers your last choice for next time
[*] Consciousness toggle is a proper checkbox now, not a button styled to look like one
[*] Addon Options are now grouped into clear sections (General/Defaults/Interaction/Permissions/Training/Scenario)
[*] Renamed "Interactive Terminal" to "Medical Terminal" everywhere - it now hints when set up correctly and warns if placed without being attached to an object
[/list]

[b]Changed/Fixed[/b]
[list]
[*] Addon Options weren't showing up in the Eden Editor at all - fixed
[*] Eden-placed AFCM Patient and Medical Terminal modules showed a solid black icon - fixed
[*] Toast notifications could render invisibly behind an open window - fixed, they now always show on top
[/list]
```
