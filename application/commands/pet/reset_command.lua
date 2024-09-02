local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local assist_state = require('application/assist_state')
local binder = require('application/binder')

local function execute()
  local me = mq.TLO.Me
  if me.Pet() ~= "NO PET" then
    mq.cmd("/pet back off")
  end

  assist_state.current_pet_target_id = 0
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/resetpet", createCommand, "Tells pet to back off and resets pet current target id.")

return execute
