# Architecture

## Roles: driver vs bots

Every toon runs the same script. Role is decided at runtime:

- **Driver / orchestrator**: the EQ window in the foreground (`core/assist.lua` `IsOrchestrator()`
  → `mq.TLO.EverQuest.Foreground()`). It shows the action bar and broadcasts commands. Combat
  actions such as nuking bail out early on the driver so the human stays in control.
- **Bots**: background instances. They run class tick logic and execute commands received
  through broadcast (MQ2DanNet/EQBC/actors via the `broadcast` submodule).

Shared combat context comes from **MQ2NetBots**: main assist/tank are resolved from ordered lists in
settings (`assist.main_assist`, `assist.tanks`) by picking the first one who is online and in zone.
The kill target is the main assist's NetBots `TargetID`, engaged at `assist.engage_at` HP%.

## Startup (`init.lua`)

1. Logger prefix, PackageMan packages, `plugins.EnsureIsLoaded` for each entry in `plugins.lua`.
2. Console widget, broadcast in `ACTOR` mode.
3. `require('bot')`. This pulls in `settings/settings` (loads + maps settings), all commands
   (`application/commands.lua`) and the GITS plugin scan.
4. Bail if GM. Init ImGui UI + action bar. `mq.delay(2000)` (lets NetBots initialise).
5. Main loop: while in game → refresh action bar every 0.5s, call `bot.Process()`, `mq.delay(1)`.

## Tick (`bot.lua` `process`)

```
mq.doevents()                     -- all chat events (casting results, enrage, medley...)
if PAUSED → return
commandQueue.Process()            -- post-command coroutines, then at most ONE queued command
if ACTIVE and not following:
  for action in classActions[class]:
    assistTick()                  -- refresh kill target before every action
    if action() then break        -- first action that did something wins this tick
  camp.Process()
elif following and bard:
  medley.OnTick()                 -- bards keep twisting while following
```

`classActions` is the per-class priority list (healers start with `doHealing`, enchanters with
`doMezz`...). Reordering changes behaviour.

## Run states (`app_state.lua`)

| State | Command queue | Class actions |
|-------|---------------|---------------|
| `ACTIVE` | runs | run |
| `CHAIN` | runs | skipped (used by CH chain so the cleric only runs the chain coroutine) |
| `PAUSED` | cleared + skipped | skipped; `/stopsong` + `/stopcast` on entry |

Toggle with `/gitstoggle <1|2|3>` (BotState enum value). The UI pause button broadcasts this to the zone.

Other state modules (plain tables, reset via `:Reset(...)`):
- `application/assist_state.lua`: mode, nuke `spell_set`, `medley`, `pbaoe_active`,
  `crowd_control_mode`, `current_target_id`, `current_pet_target_id`, `enraged`, `enable_offtanking`.
- `application/follow_state.lua`: follow `mode` (`nav`/`actor`/`advpath`/`moveutils`) and `spawn_id`.
  `:Stop()` turns off every follow plugin.
- `application/casting/casting_state.lua`, `application/looting/looterstate.lua`,
  `application/medley/state.lua`.

## Command pattern (`application/command_queue.lua`)

External input (slash commands, broadcast, UI buttons, plugins) never acts directly inside the
bind callback. It enqueues:

```lua
commandQueue.Enqueue(execute, canExecute?)
```

- `Process()` first resumes every **post-command** coroutine once, then dequeues the oldest
  command whose `CanExecute` is nil or true, and runs it.
- A command's `Execute` may return a **coroutine** (a post-command). It gets resumed once per
  tick until dead. Use it for long-running work that must not block the tick: following via nav,
  the CH chain, medley twisting. Pattern: `while condition do ... coroutine.yield() end`.
- `Clear()` (called on pause) drops both queues.

```
/slash cmd ──► binder callback ──► parse args ──► Enqueue(fn)
                                                    │
bot tick ──► Process ──► resume post-commands ──► dequeue 1 ──► fn() ──► (coroutine?) ──► postQueue
```

## Slash command registry (`application/binder.lua`)

`binder.Bind(command, callback, helpText, args?)` stores help text and calls `mq.bind`.
`/gits` prints all registered commands sorted. See [commands.md](commands.md).

## GITS plugins

`application/commands.lua` `loadPlugins("plugins")` scans `<app>/plugins/` recursively, `require`s
every file and calls the returned function with the command queue:

```lua
-- plugins/my_feature.lua
local binder = require('application/binder')
return function(commandQueue)
  binder.Bind("/myfeature", function(...)
    commandQueue.Enqueue(function() --[[ work ]] end)
  end, "Does my feature", "arg")
end
```

Plugins are maintained in the sibling repo `../ghost-in-the-shell-plugins` and deployed by copying
its `plugins/` folder here. Its AGENTS.md covers the plugin conventions. Plugins call GITS modules
directly (`application/binder`, `core/assist`, `settings/settings`...), so renaming or changing
those modules can break plugins. Grep that repo before changing them.

The folder is optional. If it's missing, nothing loads. Files that don't return a function are
skipped with a warning. MQ plugin TLO type stubs live in `definitions/` (editor only), not here.

## Casting model (`core/casting/`)

`cast.lua` base → `spell.lua` / `item.lua` / `altability.lua` / `song.lua`, then specialised
types: `buffs/`, `debuffs/`, `heals/` (heal + HoT), `nukes/`, `cures/`, `pets/`,
`conversionspell`/`conversionitem` (mana conversion). Settings mapping (`settings/settings.lua`
`ReloadSettings`) turns config entries into these objects using `spell_finder`. A spell group
resolves to the highest level spell in the spellbook; an item resolves when `FindItem` finds it.
Cast results come back via chat events in `application/casting/events.lua`.

## Broadcast / cross-toon

`broadcast/broadcastinterface('REMOTE')` → `ExecuteAllCommand`, `ExecuteZoneCommand`,
`ExecuteZoneWithSelfCommand`, `ExecuteGroupCommand`, `ExecuteCommand(cmd, receivers)`... The UI
mostly uses `ExecuteZoneWithSelfCommand` so the driver also gets the command (and decides
locally whether to act on it).

## UI (`ui/`)

- `ui/init.lua`: "Ghost in the shell" window with tabs: Console, Settings, States, Loot.
  `/gitsui` reopens it.
- `ui/actionbar.lua`: icon bar, shown only on the driver. Buttons are auto-loaded from
  `ui/actions/NN_name.lua`. The two-digit prefix is the slot index, and indices ≥ 21 start a
  second row. Each module returns `{ Render = fun(buttonSize), OnClick? = fun() }`, built with
  `ui/buttons.lua` (`ActionButton`: `active`, `icon`, `tooltip`, `isDisabled`, `activate`, `deactivate`).
- The UI is thin and incomplete. Settings tab is read-mostly. Buttons broadcast slash commands
  and don't mutate state directly.

## Layering (intended vs actual)

Intended onion: `data` ← `core` ← `application` ← `ui`/`init`, with `settings` as config input.

Actual leaks to be aware of (don't add more):
- `core/assist.lua`, `core/melee_abilities.lua`, `core/movement.lua` read `settings/settings`.
- `core/casting/*` imports `application/casting/casting_state`.
- `settings/settings.lua` imports `application/casting/spell_finder`.
- Module-level side effects: requiring a command file registers its bind, and requiring
  `settings/settings` loads files and touches TLOs.
