# Gotchas

Things that look wrong or odd but are deliberate, and known traps. Read before "cleaning up"
timing, delays or ordering. Most of these came from real in-game failures.

## Deliberate behaviour (don't "fix")

- **Global `mq.doevents()`** at the start of every tick. Triggering a single named event yields at
  least one frame, so the code always runs all events at once.
- **`mq.delay(2000)` on startup** lets MQ2NetBots initialise before assist lookups run.
- **Driver skips combat actions.** `IsOrchestrator()` = foreground window. **Alt-tabbing changes
  which toon is the driver**, and the action bar follows.
- **Pause clears the command queue** and post-command coroutines, and does `/stopsong` + `/stopcast`.
- **While following, non-bards do nothing**, except the command queue. Bards keep running their medley.
- **CHAIN state** exists so a cleric in a CH chain runs only the chain coroutine and the queue, not
  the normal heal/buff tick.
- **Item clicks are throttled.** Spam-clicking items or instant clickies has caused server-side
  disconnects. Keep timers/ready checks around item casts. Prefer the item's spell over the clicky
  where the code already does.
- **Delete / loot use separate timers** and generous delays so cursor deletes actually happen
  (pickpocket and loot both leave items on the cursor). Don't shorten them without in-game testing.
- **Nukes on cooldown are skipped, not waited for.** Waiting stalled the whole tick.
- **Only the top 2 PB AoE spells** are loaded (`settings.lua`).
- **Bard startup** forces `/bardswap` + `/bardswap melee` + `/stopsong`. Loot only handles
  bardswap, not twist.
- **Mana conversion is still used with a rune up** (rune absorbs the HP cost).
- **Cleric epic**: rez waits for the epic to be ready.
- **Zone-specific door handling** exists (Veeshan's Peak, HS). Look for it before adding generic logic.
- **Assist resets on travel/evac** so bots don't chase a stale target across zones.

## Known pitfalls / open issues

- **Nil TLOs everywhere.** Zoning, despawns and dead targets make TLO members return `nil`.
  Comparing `nil` with a number crashes the script. Guard `spawn()` first. Many commits are
  "fix nil crash".
- **Settings merge**: arrays (`tanks`, `main_assist`) merge **by position**, inherited keyed
  entries can't be removed, and wrong-typed values are silently dropped. See [settings.md](settings.md#inheritance).
- **Class settings filename** strips spaces: `shadowknight_settings.lua`, not `shadow knight_...`.
- **Config paths come from `settings/paths.lua`** (`<config>/<script folder>/<server>`). Use it for
  new per-server files.
- **`plugins/` is for GITS runtime plugins only.** MQ TLO type stubs (`---@meta`) go in
  `definitions/`. The loader skips a missing `plugins/` folder and any module that doesn't return a function.
- **`actionbar.Terminate` is copied by value** in `ui/actionbar.lua`'s return table, so closing the
  action bar never ends the `init.lua` loop. Use `/lua stop`.
- **Post-command order matters.** Coroutines run in insertion order every tick and share game state
  (target, nav, casting), so later ones can override earlier ones within a tick. A coroutine that
  errors is logged at Error with a traceback and dropped.
- **Spell constructors don't abort.** `Spell:new` logs an error for an invalid or unscribed spell but
  still returns an object.
- **Bind callbacks get strings.** Always `tonumber` and validate ids before enqueueing.
- **`utils/` and `broadcast/` are submodules.** Local edits there are lost or diverge. Change upstream
  and bump the submodule.
