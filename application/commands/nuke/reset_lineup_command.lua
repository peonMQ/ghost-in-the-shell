local mq = require("mq")
local logger = require("knightlinc/Write")
local commandQueue  = require("application/command_queue")
local config = require 'modules/nuker/config'

local function execute()
  config.CurrentLineup = config.Nukes
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

mq.bind("/resetlineup", createCommand)

return execute
