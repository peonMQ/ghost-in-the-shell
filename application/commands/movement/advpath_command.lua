local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local plugins = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local follow_state = require('application/follow_state')
local binder = require('application/binder')


local function execute(targetId)
  if not plugins.IsLoaded("mq2advpath") then
    return
  end

  follow_state.Stop()
  if not targetId then
    follow_state:Reset()
    return
  end

  local stickSpawn = mq.getFilteredSpawns(function(spawn)  return spawn.ID() == tonumber(targetId) and spawn.Type() == "PC" end)
  if stickSpawn[1] then
    follow_state:Activate('advpath', stickSpawn[1].ID())
    mq.cmdf("/afollow %s", stickSpawn[1].Name())
    mq.delay(500)
  else
    logger.Warn("Could not find spawn with id %s", targetId)
  end

  if plugins.IsLoaded("mq2advpath") and not mq.TLO.AdvPath.Active() then
    broadcast.Error("Unable to follow %s", stickSpawn[1].Name())
  end
end

local function createCommand(targetId)
  commandQueue.Enqueue(function() execute(targetId) end)
end

if plugins.IsLoaded("mq2advpath") then
  binder.Bind("/stalkadv", createCommand, "Tells the bot to follow the 'target_id' using 'mq2advpath'", 'target_id')
end
