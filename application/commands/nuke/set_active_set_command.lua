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

  local nukes = settings.assist.nukes[set_name]
  if not next(nukes or {}) then
    broadcast.FailAll("No nuke for <%s>", broadcast.ColorWrap(set_name, 'Blue'))
    return
  end

  local highest_level_spell = nil
  for _, nuke in pairs(nukes) do
    if (not highest_level_spell or nuke.MQSpell.Level() > highest_level_spell.MQSpell.Level()) and nuke:MemSpell() then
      highest_level_spell = nuke
    end
  end

  broadcast.SuccessAll("Active spell set is now %s", broadcast.ColorWrap(set_name, 'Blue'))
  assist_state.spell_set = set_name
end

local function createCommand(set_name)
    commandQueue.Enqueue(function() execute(set_name:lower()) end)
end

binder.Bind("/activespellset", createCommand, "Tells nuker to set his active nukeset to 'name'", 'name')

return execute
