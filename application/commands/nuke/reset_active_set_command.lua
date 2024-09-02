local mq = require('mq')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local assist_state = require('application/assist_state')
local binder = require('application/binder')

local function execute()
  assist_state:Reset('spell_set')
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/resetactivespellset", createCommand, "Tells the bot to reset the active nuke lineup to 'main'.")

return execute
