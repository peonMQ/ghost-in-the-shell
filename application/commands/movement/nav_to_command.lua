local mq = require("mq")
local logger = require("knightlinc/Write")
local plugins = require 'utils/plugins'
local commandQueue  = require("application/command_queue")
local follow_state = require 'application/follow_state'

local function createPostCommand()
  return coroutine.create(function ()
    while follow_state.spawn_id ~= nil do
      if not mq.TLO.Navigation.Active() then
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

  if mq.TLO.Navigation.Active() or follow_state.spawn_id then
    mq.cmd("/nav stop")
    follow_state.spawn_id = nil
    return
  end

  if plugins.IsLoaded("mqactoradvpath") and mq.TLO.ActorAdvPath.IsFollowing() then
    mq.cmd("/actfollow off")
  end

  if not targetId then
    logger.Warn("Missing <targetId> to navigate to.")
    return
  end

  local stickSpawn = mq.getFilteredSpawns(function(spawn) return spawn.ID() == tonumber(targetId) and spawn.Type() == "PC" end)
  if stickSpawn[1] and mq.TLO.Navigation.PathExists("id "..stickSpawn[1].ID()) then
    follow_state.spawn_id = stickSpawn[1].ID()
    mq.cmdf("/nav id %d", follow_state.spawn_id)
  end
end

local function createCommand(targetId)
  commandQueue.Enqueue(function() execute(targetId); return createPostCommand() end)
end

mq.bind("/navto", createCommand)
