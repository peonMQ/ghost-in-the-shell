local mq = require("mq")
local logger = require("knightlinc/Write")
local commandQueue  = require("application/command_queue")
local filetutils = require 'utils/file'
local app_state = require 'app_state'

local exportInventoryScriptExists = filetutils.Exists(mq.luaDir.."/inventory/export.lua")

local function execute()
  app_state.Pause()
  mq.cmd("/stopsong")
  mq.cmd("/stopcast")
  if exportInventoryScriptExists then
    mq.cmd('/lua run inventory/export')
  end
  mq.cmd("/camp desktop")
end

local function createCommand()
  commandQueue.Enqueue(function() execute() end)
end

mq.bind("/qtd", createCommand)

return execute