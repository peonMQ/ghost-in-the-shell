# Ghost in the Shell (GITS)

MacroQuest Lua automation for running a full EverQuest (emulator) team from one machine.
One toon is the **driver** (foreground EQ instance, played by a human). All other toons are
**bots** running the same script and reacting to the driver through broadcast commands,
NetBots data and their own per-class tick logic.

Loosely based on E3, with design and data borrowed from
[efyran](https://github.com/martinlindhe/efyran) (spell groups, class buff data).

## Runtime facts

- Lua runs **inside MacroQuest** (LuaJIT, `require('mq')`, `mq.TLO.*`, ImGui). Nothing here runs
  under a plain `lua` interpreter. Never assume you can execute code locally.
- Start in game: `/lua run <folder-name>` → `init.lua`.
- Spell data covers up to level 70 (Titanium/OoW-era emulators).
- Required MQ plugins are listed in `plugins.lua` and auto-loaded at startup
  (`mq2eqbc`, `mqremote`, `mq2netbots`, `mq2nav`, `mq2moveutils`, `mq2advpath`, `mq2bardswap`,
  `mq2debuffs`, `mq2easyfind`, `mqactorfollow`).
- Lua packages via PackageMan: `lua-cjson`, `lsqlite3`, `luafilesystem`.

## Layout

| Path | Role |
|------|------|
| `init.lua` | Entry: loads plugins, console, UI, then the main loop (`bot.Process()` each frame) |
| `bot.lua` | Per-class priority action list + tick |
| `app_state.lua`, `bot_states.lua` | Global run state: `ACTIVE` / `PAUSED` / `CHAIN` |
| `application/` | Behaviour: healing, buffing, nuking, assist, looting, medley, pets, commands |
| `application/commands/` | One file per slash command; each enqueues work on the command queue |
| `application/command_queue.lua` | Command queue + post-command coroutines |
| `application/binder.lua` | **Only** way to register slash commands (feeds `/gits` help) |
| `core/` | Lower-level MQ wrappers: casting types, movement, timers, events, assist lookup |
| `data/` | Static tables: spell groups per class, buffs, zones, ports, spell merchant locations |
| `settings/` | Default settings + inheritance loader (server → class → toon) |
| `ui/` | ImGui console window + action bar (driver only) |
| `knightlinc/Write.lua` | Logger |
| `utils/`, `broadcast/` | **Git submodules** (peonMQ/utils, peonMQ/broadcast). Edit upstream, not here |
| `plugins/` | GITS runtime plugins (optional, not in repo). They live in the sibling repo `../ghost-in-the-shell-plugins`, which has its own AGENTS.md. See docs/architecture.md |
| `definitions/` | LuaLS type stubs (`---@meta`) for MQ plugin TLOs. Editor-only, not shipped |

Deeper docs:
- [docs/architecture.md](docs/architecture.md): tick loop, command queue, states, layers, broadcast
- [docs/commands.md](docs/commands.md): every slash command and how to add one
- [docs/settings.md](docs/settings.md): settings files, inheritance and merge rules
- [docs/data-format.md](docs/data-format.md): `data/` table formats and how to add spells
- [docs/gotchas.md](docs/gotchas.md): **read before "fixing" odd-looking code**
- [docs/improvements.md](docs/improvements.md): known issues and planned changes

## Rules when changing code

- **Slash commands**: register via `binder.Bind(cmd, fn, helpText, args)`, never raw `mq.bind`
  (exceptions: `/gits` itself and `/gitstoggle`). Command callbacks parse args and
  `commandQueue.Enqueue(...)`. They don't act inline.
- **Bot actions** (`bot.lua` `classActions`) are `fun(): boolean`. Return `true` = "I did something
  this tick" and the rest of the list is skipped. Order is priority. Don't return `true` for no-ops.
- **TLO access is nil-prone.** Spawns despawn, targets vanish, zoning nils everything. Guard
  `spawn()` before reading fields and don't compare `nil` with numbers. Many past commits are nil fixes.
- **Driver check**: anything that must not run on the human-played toon checks
  `assist.IsOrchestrator()` (= `EverQuest.Foreground()`).
- **Don't spam the server**: item clicks and casts must be gated by timers/ready checks.
  Rapid clicky spam has caused disconnects.
- Prefer existing helpers: `core/timer.lua`, `core/mqevent.lua`, `utils/plugins` (`IsLoaded`),
  `application/casting/spell_finder.lua`, `broadcast/broadcastinterface('REMOTE')`.
- Logging: `logger.Debug/Info/Warn/Error` from `knightlinc/Write`. Keep noisy output at Debug.
- Style: 2-space indent, LuaLS annotations (`---@class`, `---@param`) on public functions/state.
- Layering is aspirational. `core/` currently imports `settings/` and `application/casting/casting_state`
  in places. Don't add **new** `core → application` or `application → ui` dependencies.

## Game data lookups (eqemu MCP server)

When the `eqemu` MCP server is available, use it to check game data against the server's own
database (the FV project emulator database) instead of guessing. It's read-only.

- **Spells**: `search_spells` / `get_spell` to verify names, levels, ranks and effects when editing
  `data/spells_*.lua`. Spell names must match exactly.
- **Merchants**: `search_npcs` + `get_merchant_items` for `data/spells_locations_*.lua` and
  `/sellitems` logic.
- **Items**: `search_items` / `get_item` for clickies, focus items and loot handling.
- **NPCs, zones, doors**: `get_npc`, `get_zone_info`, `get_zone_doors` (e.g. zone-specific door handling).
- Anything else: `list_tables` / `describe_table` + `run_query`.

Data here reflects this server's era and customisations, so prefer it over general EQ knowledge.

## Verification

### Static check (run after every change)

No Lua interpreter is installed. The VS Code Lua extension (sumneko) ships `lua-language-server`,
whose `--check` mode type-checks the repo from the command line. It does **not** read
`.vscode/settings.json`, so give it a config with the same libraries via `--configpath`.

1. Write a config **outside the repo** (e.g. your scratch/temp dir) as `luarc.json`. Take the library
   paths from `Lua.workspace.library` in `.vscode/settings.json`, made absolute:

```json
{
  "runtime.version": "LuaJIT",
  "workspace.library": [
    "<repo>/broadcast",
    "<repo>/utils",
    "<repo>/definitions",
    "C:/Development/PeonMQ/mq-plugin-definitions2",
    "<VS Code globalStorage>/zenithcodeforge.mq-defs/file-downloader-downloads/macroquest/mq-definitions-master"
  ],
  "workspace.ignoreDir": ["utils", "broadcast", "definitions", ".git"],
  "diagnostics.groupFileStatus": { "type-check": "Any" }
}
```

2. Run (Git Bash; the extension version in the path changes on updates):

```sh
LLS=~/.vscode/extensions/sumneko.lua-*-win32-x64/server/bin/lua-language-server.exe
$LLS --check="$(pwd -W)" --configpath="<scratch>/luarc.json" --checklevel=Warning --logpath="<scratch>/lls" \
  | sed 's/\x1b\[[0-9;]*m//g' | grep -E '^\S+\.lua:|problems'
```

- Baseline: **2 warnings**, both `param-type-mismatch` from nuke sets that may hold a `NukeItem`
  where a spell is expected: `application/commands/nuke/set_active_set_command.lua:23` and
  `application/nuke.lua:96`. Anything new comes from your change.
- Hundreds of `undefined-global ImGui`/`mq` warnings mean the MQ definition paths are wrong, not the code.
- Without the config, `--checklevel=Error` still catches syntax errors.
- It catches nil fields, wrong arguments and typos. It can't catch runtime behaviour, which needs in-game testing.

### In game

No automated test runner. `tests.lua` only loads settings and dumps them (`/lua run <folder>/tests`).
Verify changes in-game on a bot toon: run with `loglevel = 'debug'` in the toon's settings file and
watch the GITS console tab. When you can't verify something, say what needs in-game testing.

## Release

`.github/workflows/cd.yml` builds a zip on GitHub release publish. Excludes `.github`, `.vscode`,
`definitions/` and copies `utils/`, `utils/loaders/`, `broadcast/` as flat libs. New subfolders under
`utils/` need adding to the `CopyLib` calls.
