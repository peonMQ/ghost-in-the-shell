local mq = require('mq')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local assist_state = require('application/assist_state')

local function execute(zone_name)
  logger.Debug("Entered %s", zone_name)
  assist_state.pbaoe_active = false
end

local function createCommand(zone_name)
  commandQueue.Enqueue(function() execute(zone_name) end)
end

mq.event('zoned', 'You have entered #*#', createCommand)

return execute

