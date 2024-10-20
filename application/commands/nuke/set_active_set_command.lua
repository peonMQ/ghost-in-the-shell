local mq = require('mq')
local broadcast = require('broadcast/broadcast')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local settings = require('settings/settings')
local assist_state = require('application/assist_state')
local binder = require('application/binder')

local function execute(set_name)
  if not set_name or not settings.assist.nukes[set_name] then
    logger.Warn("Spell set '%s' does not exist in settings.", set_name)
    return
  end

  broadcast.SuccessAll("Active spell set is now %s", broadcast.ColorWrap(set_name, 'Blue'))
  assist_state.spell_set = set_name
end

local function createCommand(set_name)
    commandQueue.Enqueue(function() execute(set_name:lower()) end)
end

binder.Bind("/activespellset", createCommand, "Tells nuker to set his active nukeset to 'name'", 'name')

return execute
