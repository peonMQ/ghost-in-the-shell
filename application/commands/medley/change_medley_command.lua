local mq = require("mq")
local logger = require("knightlinc/Write")
local commandQueue  = require("application/command_queue")
local settings = require 'settings/settings'
local assist_state = require 'application/assist_state'

local function execute(set_name)
  if not set_name or not settings.medleys[set_name] then
    logger.Warning("Medley set '%s' does not exist in settings.", set_name)
    return
  end

  logger.Info("Active medley set is now '%s'", set_name)
  assist_state.medley = set_name
end

local function createCommand(set_name)
    commandQueue.Enqueue(function() execute(set_name) end)
end

mq.bind("/activemedley", createCommand)

return execute
