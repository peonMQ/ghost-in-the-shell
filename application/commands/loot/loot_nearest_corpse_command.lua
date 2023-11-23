local mq = require("mq")
local logger = require("knightlinc/Write")
local commandQueue  = require("application/command_queue")
local lootNearestCorpse = require 'modules/looter/loot'

local function execute(seekRadius)
  local count = mq.TLO.SpawnCount(string.format("npccorpse zradius 50 radius %d", seekRadius))()
  if count == 0 then
    logger.Debug("/doloot: Finished looting area!")
    return
  end

  lootNearestCorpse(seekRadius)
  logger.Info("Loot nearest corpse command completed.")
end

local function createCommand(seekRadius)
    commandQueue.Enqueue(function() execute(seekRadius or 50) end)
end

mq.bind("/doloot", createCommand)
