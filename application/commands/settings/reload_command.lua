local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local commandQueue  = require("application/command_queue")
local settings = require 'settings/settings'

local function execute()
  logger.Info("Reloading bot settings...")
  broadcast.InfoAll("Reloading bot settings...")
  settings:ReloadSettings()
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

mq.bind("/reloadsettings", createCommand)
mq.event("gainlevel", "You have gained a level!#*#", createCommand)
mq.event("scribed_spell", "You have finished scribing #*#", createCommand)

return execute
