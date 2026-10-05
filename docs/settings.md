# Settings

Settings are Lua files that `return { ... }`. They're loaded and merged by `settings/loader.lua`,
then mapped into casting objects by `settings/settings.lua` (`ReloadSettings`).

## File locations

Under `<MQ config dir>/<script folder>/<server short name>/`:

| Level | File | Example |
|-------|------|---------|
| Server | `server_settings.lua` | shared by every toon on the server |
| Class | `<classname>_settings.lua` | class name lowercased, **spaces removed**: `shadowknight_settings.lua`, `cleric_settings.lua` |
| Toon | `bots/<toonname>_settings.lua` | `bots/gandalf_settings.lua` (lowercase) |

Missing files are fine and are treated as `{}`.

Loot data: `<same dir>/data/loot_settings.lua`. The base path is built in `settings/paths.lua`.

## Inheritance

```
defaults (settings/settings.lua) ← server ← class ← toon      (right wins)
```

Merge rules (`leftJoin`). Each layer merges onto the **accumulated** result of the layers before it:

1. **Keyed tables** (`buffs.self`, `assist.nukes`, `heal.hot`...): merged by key, i.e. a union, and
   nested data fields merge too. Class `{a, b}` + toon `{c}` → `{a, b, c}`. An inherited entry
   **can't be removed** (`a = false` is ignored).
2. **Arrays** (`assist.tanks`, `assist.main_assist`, medley song lists): **merged by position**.
   Class `{'A','B'}` + toon `{'C'}` → `{'C','B'}`. To shorten a list, override it at the same length.
3. **Keys in `notMergeTableKeys`** are replaced wholesale wherever the key name appears: `mt_heal`,
   `mt_emergency_heal`, `default`, `ae_group`.
4. **Scalars**: replaced if the type matches the inherited value's type, or the inherited value is
   nil/`false`. A wrong type (e.g. `range = "100"`) is **silently ignored**. A `false` default
   accepts any type.

Planned changes: [improvements.md](improvements.md#settings-merge).

`/reloadsettings` re-reads all three files and re-maps spells (also `/loot_reload` for loot).

## Schema (defaults)

```lua
{
  loglevel = 'info',            -- trace|debug|info|warn|error|fail
  looter = false,               -- responds to /doloot
  isLockpicker = false,
  gems = { default = 5 },       -- gem per spell group/name; fallback 'default'
  cures = {},                   -- [group_or_spell] = { MinManaPercent, GiveUpTimer }
  mana = {
    meditate = 90,              -- sit below this %
    meditate_with_mob_in_camp = false,
    conversions = {},           -- [group_or_spell_or_item] = { StartManaPct, StopHPPct }
  },
  assist = {
    type = nil,                 -- 'melee'|'ranged'|nil
    require_los = true,
    range = 100,
    engage_at = 90,             -- engage at mob HP %
    tanks = {},                 -- ordered names; first online+in zone is MT
    main_assist = {},           -- ordered names; first online+in zone is MA
    nukes = {},                 -- [set_name] = { [group_or_spell_or_item] = { MinManaPercent, GiveUpTimer } }
    debuffs = {},               -- [group_or_spell] = { MinManaPercent, GiveUpTimer, MaxResists }
    dots = {},
    pbaoe = {}, aoe_stuns = {}, -- auto-filled from <cls>_pbae_nuke / <cls>_ae_stun groups, don't set
  },
  buffs = {
    self = {}, combat = {}, request = {},   -- [group_or_spell_or_item] = { MinManaPercent, GiveUpTimer, ClassRestrictions }
    requestInCombat = false,
  },
  heal = {                      -- each: [group_or_spell] = { MinManaPercent, GiveUpTimer, HealPercent, HealDistance }
    -- default, mt_heal, mt_emergency_heal, hot, ae_group
  },
  pet = {
    type = nil,                 -- see data/spells_pet.lua; invalid type → pet = nil
    engage_at = 0, taunt = false,
    buffs = {}, combatbuffs = {},
  },
  medleys = nil,                -- bards: [name] = { "song or group", ... } (index = gem)
  medleyPadTimeMs = 0,
}
```

Keys of spell tables are a **spell group name** from `data/spells_<class>.lua` (preferred: picks
the highest level spell in your book, so it auto-upgrades), an exact spell name, or an item name
(where items are supported). Unresolvable entries are dropped from the mapped settings, and
spell group lookups log a warning.

## Example toon file

```lua
-- <config>/<script>/<server>/bots/clericone_settings.lua
return {
  loglevel = 'debug',
  gems = { clr_heal = 1, clr_complete_heal = 2, default = 8 },
  assist = {
    main_assist = { 'Tankone', 'Tanktwo' },
    tanks = { 'Tankone', 'Tanktwo' },
  },
  heal = {
    mt_heal = { clr_complete_heal = { HealPercent = 60, MinManaPercent = 0 } },
  },
}
```

Group names come from `data/spells_cleric.lua`.

## Adding a setting

1. Add the field with a default to `default_settings` and its `---@field` annotation in
   `settings/settings.lua`. The default's **type** decides which overrides are accepted.
2. If it maps to spells/items, add mapping in `ReloadSettings`.
3. Document it here.
