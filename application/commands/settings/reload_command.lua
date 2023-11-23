local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local commandQueue  = require("application/command_queue")
local settings = require 'settings/settings'

local function execute()
  settings:ReloadSettings()
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

mq.bind("/reloadsettings", createCommand)
mq.event("gainlevel", "You have gained a level!#*#", createCommand)

return execute
