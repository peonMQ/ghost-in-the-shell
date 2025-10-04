local mq = require('mq')
local logger = require('knightlinc/Write')
local plugins = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local follow_state = require('application/follow_state')
local assist_state = require('application/assist_state')
local binder = require('application/binder')

local function execute(zoneShortName)
  if not plugins.IsLoaded("mq2nav") and not not plugins.IsLoaded("mq2easyfind") then
    return
  end

  follow_state:Stop()
  assist_state:Reset('current_target_id', 'current_pet_target_id')

  mq.cmdf("/travelto %s", zoneShortName)
end

local function createCommand(zoneShortName)
  if mq.TLO.Me.Casting.ID() and mq.TLO.Me.Class.ShortName() ~= "BRD" then
    mq.cmd("/stopcast")
  end

  commandQueue.Enqueue(function() execute(zoneShortName) end)
end

if plugins.IsLoaded("mq2nav") then
  binder.Bind("/easyfindto", createCommand, "Tells the bot to travel to the 'zone_short_name' using 'mq2easyfind'", 'zone_short_name')
end
