local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local mqutil = require('utils/mqhelpers')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')


local function execute()
  local me = mq.TLO.Me.Name()
  if mqutil.EnsureTarget(mq.TLO.Spawn(me.."'s").ID()) then
    logger.Debug("Corpse distance <%s>", mq.TLO.Target.Distance())
    if mq.TLO.Target.Distance() and mq.TLO.Target.Distance() < 100 then
      while mq.TLO.Target.Distance() > 15 do
        mq.cmd("/corpse")
        mq.delay(20)
      end

      mq.cmd("/loot")
      mq.delay("5s", function() return mq.TLO.Window("LootWnd") ~= nil and mq.TLO.Window("LootWnd").Open() end)
      mq.delay("5s", function() return mq.TLO.Corpse.Items() ~= nil end)
      mq.delay(500)
      if not mq.TLO.Window("LootWnd") or not mq.TLO.Corpse.Items then
        broadcast.FailAll("Could not open loot window.")
      else
        mq.cmd("/notify LootWnd LootAllButton leftmouseup")
        mq.delay("30s", function() return not mq.TLO.Window("LootWnd").Open() end)
      end

      broadcast.SuccessAll("Corpse looted, ready for action.")
    else
      logger.Debug("Corpse out of range. Could not loot.")
      broadcast.FailAll("Corpse out of range. Could not loot.")
    end
  end
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/lootcorpse", createCommand, "Tells bot to loot his/her corpse")

return execute
