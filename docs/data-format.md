# Data tables (`data/`)

Static Lua tables, mostly derived from [efyran](https://github.com/martinlindhe/efyran). Pure
data: no MQ calls at require time, except where noted.

## Spell groups: `spells_<class>.lua`

```lua
return {
  wiz_fire_nuke = {
    "Ancient: Core Fire",   -- L70 Ancient: Core Fire (4070 hp, resist adj -10, cost 850 mana, 8s cast)
    "Corona Flare",         -- L70 ...
  },
}
```

- Key: `<classprefix>_<purpose>` (`wiz_`, `clr_`, `shm_`, `enc_`...). This is what settings reference.
- Value: list of spell names, **highest level first** by convention. Resolution
  (`spell_finder.FindGroupSpell`) picks the highest level spell **present in the spellbook**
  (matching by `RankName`), so order is for readability, not correctness.
- Comment per line: `-- L<level> <name> (<effect summary>)`. Keep this format, it's how
  levels get audited.
- Note stacking conflicts in a `-- NOTE:` above the group.
- Magic group names used by code (don't rename): `<cls>_pbae_nuke` (top 2 loaded as PB AoE),
  `<cls>_ae_stun`. Grep for others before renaming any group.

## Aggregates

| File | Content |
|------|---------|
| `spell_groups.lua` | `ClassShortName → spells_<class>` table (BRD, BST, BER, CLR, ...). Add new class files here |
| `spell_lookups.lua` | Reverse map `group_name → ClassShortName` (built from `spell_groups`) |
| `spells_cures.lua` | Cure groups, used as fallback for any class in `FindGroupSpell` |
| `class_buffs.lua` | Per-class list of buff groups that class wants, with restrictions like `NotClass = { 'ENC' }` |
| `spells_pet.lua` | Pet spell types; callable `spells_pet(type)`, falsy if invalid |
| `spells_ports.lua` | Port/evac spells by zone (used by `/port`, `/evac`) |
| `spells_mesmerize.lua` | Mez spells/metadata for enchanter crowd control |
| `npc_belly_casters.lua` | NPCs to treat as belly casters |
| `spell_spa.lua` | SPA ids → names (spell effect attribute ids from the emulator spell file) |
| `spell_category.lua` | Spell category ids → names |
| `zones.lua` | Zone metadata |
| `spells_locations_<class>.lua` | Where to buy spells: `["Spell"] = { level, merchants = { zone_short = {"Npc_Name"} } }` |

## Adding / changing spells

1. Find the group in `spells_<class>.lua` (or add a new `<cls>_<purpose>` key).
2. Insert the spell in level order with a `-- L<lvl> ...` comment.
3. Spell name must match the in-game name exactly (`mq.TLO.Spell(name)` must resolve).
4. If it's a new group, reference it from class/toon settings (see [settings.md](settings.md)).
5. Check in game: `/reloadsettings` with `loglevel = 'debug'` shows
   "Found new/upgraded spell in book".

## Adding a class data file

Create `spells_<class>.lua`, then add it to `spell_groups.lua` under the class short name.
`spell_lookups` updates automatically.
