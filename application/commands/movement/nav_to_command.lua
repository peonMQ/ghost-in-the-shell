local mq = require('mq')
local logger = require('knightlinc/Write')
local plugins = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local follow_state = require('application/follow_state')
local binder = require('application/binder')

local function createPostCommand()
  return coroutine.create(function ()
    while follow_state.spawn_id ~= nil do
      if not mq.TLO.Navigation.Active() and not mq.TLO.Me.Combat() then
        local stickSpawn = mq.getFilteredSpawns(function(spawn) return spawn.ID() == tonumber(follow_state.spawn_id) and spawn.Type() == "PC" end)
        if stickSpawn[1] and stickSpawn[1].Distance() > 20 and mq.TLO.Navigation.PathExists("id "..stickSpawn[1].ID()) then
          mq.cmdf("/nav id %d", stickSpawn[1].ID())
        end
      end

      coroutine.yield()
    end
  end)
end

local function execute(targetId)
  if not plugins.IsLoaded("mq2nav") then
    return
  end

  follow_state.Stop()
  if not targetId then
    follow_state:Reset()
    return
  end

  local stickSpawn = mq.getFilteredSpawns(function(spawn) return spawn.ID() == tonumber(targetId) and spawn.Type() == "PC" end)
  if stickSpawn[1] and mq.TLO.Navigation.PathExists("id "..stickSpawn[1].ID()) then
    follow_state:Activate('nav', stickSpawn[1].ID())
    mq.cmdf("/nav id %d", follow_state.spawn_id)
  end
end

local function createCommand(targetId)
  if mq.TLO.Me.Casting.ID() and mq.TLO.Me.Class.ShortName() ~= "BRD" then
    mq.cmd("/stopcast")
  end

  commandQueue.Enqueue(function() execute(targetId); return createPostCommand() end)
end

if plugins.IsLoaded("mq2nav") then
  binder.Bind("/navto", createCommand, "Tells the bot to follow the 'target_id' using 'mq2nav'", 'target_id')
end
