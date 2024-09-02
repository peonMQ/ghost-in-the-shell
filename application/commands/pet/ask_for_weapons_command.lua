local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local plugins = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')

local function execute(characterName)
  if not mq.TLO.Me.Pet.ID() then
    return
  end

  if not characterName then
    logger.Debug("Cold not ask for weapons, param <charactername> is nil")
    return
  end

  if plugins.IsLoaded("mq2netbots") and mq.TLO.NetBots(characterName).InZone() then
    mq.cmdf("/bct %s //weaponizepet %d", characterName, mq.TLO.Me.Pet.ID())
  else
    logger.Debug("Cold not ask <%s> for weapons, NetBots not loaded or character not in zone.", characterName)
  end
end

local function createCommand(characterName)
    commandQueue.Enqueue(function() execute(characterName) end)
end

binder.Bind("/askforpetweapons", createCommand, "Tells bot to ask 'character_name' to weaponize his/her pet", 'character_name')

return execute
