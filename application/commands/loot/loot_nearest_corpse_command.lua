local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local settings = require('settings/settings')
local binder = require('application/binder')
local lootNearestCorpse = require('application/looting/loot')

local function execute(seekRadius)
  local count = mq.TLO.SpawnCount(string.format("npccorpse zradius 50 radius %s", seekRadius))()
  if count == 0 then
    logger.Debug("Found no corpse to loot.")
    return
  end

  lootNearestCorpse(seekRadius)
end

local function createCommand(seekRadius)
  if settings.looter then
    commandQueue.Enqueue(function() execute(seekRadius or 50) end)
  end
end

binder.Bind("/doloot", createCommand, "Tells bots with 'loot' setting to loot nearest corpse, optional param corpse radius (default 50)", 'radius')
