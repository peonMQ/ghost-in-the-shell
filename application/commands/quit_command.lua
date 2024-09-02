local mq = require('mq')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local filetutils = require('utils/file')
local app_state = require('app_state')
local binder = require('application/binder')

local exportInventoryScriptExists = filetutils.Exists(mq.luaDir.."/inventory/export.lua")

local function execute()
  app_state.Pause()
  if exportInventoryScriptExists then
    mq.cmd('/lua run inventory/export')
  end
  mq.cmd("/camp desktop")
end

local function createCommand()
  if app_state.IsActive() then
    commandQueue.Enqueue(function() execute() end)
  else
    app_state.Activate()
    mq.cmd("/stand")
  end
end

binder.Bind("/qtd", createCommand, "Tells bot to pause bot and quit to desktop")

return execute