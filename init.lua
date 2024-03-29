local mq = require 'mq'
local logger = require("knightlinc/Write")

logger.prefix = string.format("\at%s\ax", "[GITS]")
logger.postfix = function () return string.format(" %s", os.date("%X")) end

local packageMan = require('mq/PackageMan')
packageMan.Require('lua-cjson', 'cjson')
packageMan.Require('lsqlite3')
packageMan.Require('luafilesystem', 'lfs')

local plugins = require 'utils/plugins'
local common = require 'lib/common/common'
local timer = require 'lib/timer'
local actionbar = require 'actionbar'
local bot = require 'bot'

actionbar.Init()

local ui_refresh_timer = timer:new(0.5)

while not actionbar.Terminate do
  if ui_refresh_timer:IsComplete() then
    actionbar.Process(common.IsOrchestrator())
    ui_refresh_timer:Reset()
  end

  bot.Process()
  mq.delay(1)
end