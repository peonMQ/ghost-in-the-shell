local mq = require('mq')
local logger = require('knightlinc/Write')

logger.prefix = string.format("\at%s\ax", "[GITS]")
logger.postfix = function () return string.format(" %s", os.date("%X")) end

local packageMan = require('mq/PackageMan')
packageMan.Require('lua-cjson', 'cjson')
packageMan.Require('lsqlite3')
packageMan.Require('luafilesystem', 'lfs')

local broadcast = require('broadcast/broadcast')

local CONSOLE = ImGui.ConsoleWidget.new("##GITConsole")
CONSOLE.maxBufferLines = 1000

broadcast.prefix = string.format("\at[%s]\ax", mq.TLO.Me.Name())
broadcast.postfix = function () return string.format("%s ", os.date("%X")) end
broadcast.SetMode('ACTOR', CONSOLE)
logger.console = CONSOLE

local gitsUI = require('ui/init')
local plugins = require('utils/plugins')
local assist = require('core/assist')
local timer = require('core/timer')
local actionbar = require('ui/actionbar')
local bot = require('bot')

-- require('ui.settings')

if mq.TLO.Me.GM() then
  logger.Fatal("Cannot run GM character with GITS...")
  return
end

gitsUI.Init(CONSOLE)
actionbar.Init()

local ui_refresh_timer = timer:new(0.5)

mq.delay(500)

while not actionbar.Terminate do
  local inGame = mq.TLO.EverQuest.GameState()
  if inGame == 'INGAME' then
    if ui_refresh_timer:IsComplete() then
      actionbar.Process(assist.IsOrchestrator())
      ui_refresh_timer:Reset()
    end

    bot.Process()
  end

  mq.delay(1)
end