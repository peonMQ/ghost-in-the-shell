local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local plugins = require 'utils/plugins'
local commandQueue  = require("application/command_queue")

local function execute(targetId)
  if not plugins.IsLoaded("mqactorfollow") then
    return
  end

  if plugins.IsLoaded("mqactorfollow") and mq.TLO.ActorFollow.IsFollowing() then
    mq.cmd("/actfollow off")
  end

  if plugins.IsLoaded("mq2nav") and mq.TLO.Navigation.Active() then
    mq.cmd("/nav stop")
  end

  if not targetId then
    logger.Warn("Missing <targetId> to follow.")
    return
  end

  local stickSpawn = mq.getFilteredSpawns(function(spawn)  return spawn.ID() == tonumber(targetId) and spawn.Type() == "PC" end)
  if stickSpawn[1] then
    mq.cmdf("/actfollow %s", stickSpawn[1].Name())
  else
    logger.Warn("Could not find spawn with id %s", targetId)
  end

  mq.delay(500)

  if plugins.IsLoaded("mqactorfollow") and not mq.TLO.ActorFollow.IsFollowing() then
    broadcast.Error("Unable to follow %s", stickSpawn[1].Name())
  end
end

local function createCommand(targetId)
  commandQueue.Enqueue(function() execute(targetId) end)
end

mq.bind("/stalk", createCommand)
