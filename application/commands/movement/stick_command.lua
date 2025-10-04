local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local plugins = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local follow_state = require('application/follow_state')
local assist_state = require('application/assist_state')
local binder = require('application/binder')

local function execute(targetId)
  if not plugins.IsLoaded("mq2moveutils") then
    return
  end

  follow_state:Stop()
  if not targetId then
    follow_state:Reset()
    return
  end

  local stickSpawn = mq.getFilteredSpawns(function(spawn)  return spawn.ID() == tonumber(targetId) and spawn.Type() == "PC" end)
  if stickSpawn[1] then
    follow_state:Activate('moveutils', stickSpawn[1].ID())
    assist_state:Reset('current_target_id', 'current_pet_target_id')
    if(follow_state.spawn_id ~= mq.TLO.Me.ID()) then
      mq.cmdf("/squelch /stick id %d snaproll %d uw", stickSpawn[1].ID(), 20)
    end

    mq.delay(500)
  else
    logger.Warn("Could not find spawn with id %s", targetId)
  end

  if plugins.IsLoaded("mq2moveutils") and not mq.TLO.Stick.Active() then
    broadcast.Error("Unable to follow %s", stickSpawn[1].Name())
  end
end

local function createCommand(targetId)
  commandQueue.Enqueue(function() execute(targetId) end)
end

if plugins.IsLoaded("mq2moveutils") then
  binder.Bind("/gitstick", createCommand, "Tells the bot to follow the 'target_id' using 'mq2moveutils'", 'target_id')
end
