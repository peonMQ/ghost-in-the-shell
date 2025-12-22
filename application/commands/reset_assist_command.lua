local mq = require('mq')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local assist_state = require('application/assist_state')
local binder = require('application/binder')

local function execute()
  assist_state.current_target_id = 0
  assist_state.current_pet_target_id = 0
end

local function createCommand()
  commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/resetkillit", createCommand, "Tells bot to set reset his/hers current kill target")

return execute