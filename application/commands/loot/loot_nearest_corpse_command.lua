local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local commandQueue  = require("application/command_queue")
local settings = require 'settings/settings'
local lootNearestCorpse = require 'modules/looter/loot'

local function execute(seekRadius)
  local count = mq.TLO.SpawnCount(string.format("npccorpse zradius 50 radius %d", seekRadius))()
  if count == 0 then
    logger.Debug("Found no corpse to loot.")
    return
  end

  lootNearestCorpse(seekRadius)

  logger.Info("Loot nearest corpse command completed.")
  broadcast.SuccessAll("Loot nearest corpse command completed.")
end

local function createCommand(seekRadius)
  if settings.looter then
    commandQueue.Enqueue(function() execute(seekRadius or 50) end)
  end
end

mq.bind("/doloot", createCommand)
