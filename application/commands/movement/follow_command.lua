local mq = require("mq")
local logger = require("knightlinc/Write")
local plugins = require 'utils/plugins'
local commandQueue  = require("application/command_queue")

local function execute(targetId)
  if not plugins.IsLoaded("mq2advpath") then
    return
  end

  if mq.TLO.AdvPath.Following() then
    mq.cmd("/afollow off")
    return
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
    mq.cmdf("/afollow spawn %d", stickSpawn[1].ID())
  end
end

local function createCommand(targetId)
    commandQueue.Enqueue(function() execute(targetId) end)
end

mq.bind("/stalk", createCommand)