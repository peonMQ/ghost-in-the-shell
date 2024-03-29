local mq = require("mq")
local logger = require("knightlinc/Write")
local commandQueue  = require("application/command_queue")
local settings = require 'settings/settings'
local assist_state = require 'application/assist_state'

local function execute(set_name)
  if not set_name or not settings.assist.nukes[set_name] then
    logger.Warning("Spell set '%s' does not exist in settings.", set_name)
    return
  end

  logger.Info("Active spell set is now '%s'", set_name)
  assist_state.spell_set = set_name
end

local function createCommand(set_name)
    commandQueue.Enqueue(function() execute(set_name) end)
end

mq.bind("/activespellset", createCommand)

return execute
