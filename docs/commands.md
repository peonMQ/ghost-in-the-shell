# Slash commands

In game, `/gits` prints the live list. This file mirrors it for offline reference. Update it when
adding a command.

## Core / state

| Command | Args | Description |
|---------|------|-------------|
| `/gits` | | Print all registered GITS commands |
| `/gitsui` | | Show the GITS console window |
| `/gitstoggle` | `1\|2\|3` | Set run state: 1 ACTIVE, 2 PAUSED, 3 CHAIN (raw `mq.bind`, no help entry) |
| `/reloadsettings` | | Reload settings files |
| `/qtd` | | Pause bot and quit to desktop |
| `/memspells` | | Memorize spells per `gems` setting |

## Assist / combat

| Command | Args | Description |
|---------|------|-------------|
| `/killit` | `target_id` | Set current kill target (and pet target) |
| `/resetkillit` | | Reset current kill target |
| `/activespellset` | `name` | Set active nuke set (`assist.nukes.<name>`) |
| `/resetactivespellset` | | Reset nuke set to `main` |
| `/pbaoe` | `on\|off` | Toggle PB AoE nuking |
| `/debuffs` | `on\|off` | Toggle debuff casting |
| `/crowdcontrol` | `single_mez\|ae_mez\|unresistable_mez\|nil` | Enchanter auto-mez mode |
| `/pacify` | `target_id` | Enchanter pacifies target |
| `/togglecamp` | `x y z` | Set camp at location; no args clears |

## Healing / rez / death

| Command | Args | Description |
|---------|------|-------------|
| `/ch` | | Toggle casting Complete Heal on MT |
| `/chchain` | | Toggle running a CH chain (uses CHAIN state) |
| `/rez` | `id` | Resurrect spawn id |
| `/rezgroup` | | Clerics rez group members they can |
| `/youdied` | | Put bot in dead / wait-for-rez mode |
| `/lootcorpse` | | Loot own corpse |

## Buffs

| Command | Args | Description |
|---------|------|-------------|
| `/cleanbuffs` | `duration` | Remove buffs with less than `duration` seconds left |

## Bard

| Command | Args | Description |
|---------|------|-------------|
| `/activemedley` | `name` | Set active medley (`medleys.<name>`) |

## Movement

| Command | Args | Description |
|---------|------|-------------|
| `/stalk` | `target_id` | Follow via MQActorFollow |
| `/stalkadv` | `target_id` | Follow via MQ2AdvPath |
| `/navto` | `target_id` | Follow via MQ2Nav (post-command coroutine re-navs) |
| `/gitstick` | `target_id` | Follow via MQ2MoveUtils stick |
| `/easyfindto` | `zone_short_name` | Travel to zone via MQ2EasyFind |
| `/port` | `zone_short_name` | Teleport with matching port spell |
| `/evac` | `zone_short_name` | Evac with matching spell |
| `/clickdoor` | | Click nearest door in range |
| `/lockpick` | | Lockpick nearest door (if `isLockpicker`) |
| `/enterinstance` | | Nav to nearest "agent of change" and say ready |

## Pets

| Command | Args | Description |
|---------|------|-------------|
| `/summonpet` | | Summon pet (pet classes) |
| `/setpettype` | `type` | Set active summon pet spell type |
| `/dismisspet` | | Dismiss pet |
| `/resetpet` | | Pet back off, reset pet target |
| `/weaponizepet` | `pet_id` | Give weapons to pet |
| `/askforpetweapons` | `character_name` | Ask a mage to weaponize my pet |

## Loot / selling

| Command | Args | Description |
|---------|------|-------------|
| `/doloot` | `radius` | Looters loot nearest corpse (default radius 50) |
| `/setsellitem` | | Mark cursor item sellable |
| `/setdestroyitem` | | Mark cursor item destroyable |
| `/sellitems` | | Go to nearest merchant and sell marked items |
| `/loot_reload` | | Reload loot settings file (broadcast to all after edits) |

## Adding a command

1. Create `application/commands/<area>/<name>_command.lua`:

```lua
local mq = require('mq')
local logger = require('knightlinc/Write')
local commandQueue = require('application/command_queue')
local binder = require('application/binder')

local function execute(value)
  -- do the work; optionally return coroutine.create(function() ... coroutine.yield() ... end)
end

local function createCommand(arg)
  local value = tonumber(arg)
  if not value then
    logger.Error("Usage: /mycommand <number>")
    return
  end
  commandQueue.Enqueue(function() return execute(value) end)
end

binder.Bind("/mycommand", createCommand, "What it does", 'number')

return execute
```

2. `require` it from the area's `commands.lua` (or from `application/commands.lua` for top-level ones).
3. Bind callbacks receive **strings**. Parse and validate before enqueueing.
4. If the driver should trigger it on everyone, add a UI action or broadcast via
   `bci.ExecuteZoneWithSelfCommand("/mycommand ...")`.
5. Add a row to this file.
