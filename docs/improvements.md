# Improvements

Known issues and planned changes. Not started unless noted. Describe current behaviour in the other
docs. This file is for what should change and why.

## Settings merge

`settings/loader.lua` `leftJoin`. Current behaviour is documented in
[settings.md](settings.md#inheritance).

| Problem | Example | Proposal |
|---------|---------|----------|
| Arrays merge by position | class `tanks = {'A','B'}` + toon `{'C'}` → `{'C','B'}` | If the override value is a list (`#value > 0`), replace instead of merging |
| Inherited keyed entries can't be removed | toon can't drop one class `buffs.self` entry | `key = false` removes the inherited entry |
| Wrong-type values dropped silently | `range = "100"` ignored | Log a warning with file + key path |
| `false` default skips the type check | `looter = "yes"` accepted | Accept any type only when the inherited value is `nil` |
| `notMergeTableKeys` matches by key name at any depth | `default` replaces any table named `default` | Keep for now; revisit if it collides |

Check before changing: no settings file relies on positional array merge.

## UI

- `ui/actionbar.lua` returns `Terminate` by value, so closing the action bar never stops the
  `init.lua` loop. Expose a function (`IsTerminated()`) or a shared state table instead.
- The settings tab is read-mostly. Editing and saving per-level (server/class/toon) is missing.
- More state visibility (follow mode, active nuke set, medley, queue contents).

## Architecture / layering

Intended onion: `data` ← `core` ← `application` ← `ui`. Current leaks:

- `core/assist.lua`, `core/melee_abilities.lua`, `core/movement.lua` read `settings/settings`.
  Pass the needed values in, or move the logic to `application/`.
- `core/casting/*` imports `application/casting/casting_state`.
- `settings/settings.lua` imports `application/casting/spell_finder` (settings mapping is
  application logic living in the config layer).
- Requiring a module has side effects (binds, file loads, TLO reads). This makes load order matter
  and blocks offline testing.

## Robustness

- `Spell:new` logs an error for an invalid or unscribed spell but still returns an object.
  Return `nil` so callers drop it.

## Testing

- `tests.lua` only dumps settings. The merge logic in `settings/loader.lua` is pure Lua and could
  get a self-check runnable without MQ (no `mq` require at module top level needed for `leftJoin`).
