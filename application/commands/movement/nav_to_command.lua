local mq = require("mq")
local logger = require("knightlinc/Write")
local plugins = require 'utils/plugins'
local commandQueue  = require("application/command_queue")

local function execute(targetId)
  if not plugins.IsLoaded("mq2nav") then
    return
  end

  if mq.TLO.Navigation.Active() then
    mq.cmd("/nav stop")
    return
  end

  if plugins.IsLoaded("mq2advpath") and mq.TLO.AdvPath.Following() then
    mq.cmd("/afollow off")
  end

  if not targetId then
    logger.Warn("Missing <targetId> to navigate to.")
    return
  end

  local stickSpawn = mq.getFilteredSpawns(function(spawn) return spawn.ID() == tonumber(targetId) and spawn.Type() == "PC" end)
  if stickSpawn[1] and mq.TLO.Navigation.PathExists("id "..stickSpawn[1].ID()) then
    mq.cmdf("/nav id %d", stickSpawn[1].ID())
  end
end

local function createCommand(targetId)
    commandQueue.Enqueue(function() execute(targetId) end)
end

mq.bind("/navto", createCommand)
