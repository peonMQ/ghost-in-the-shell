local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')

local function execute()
  if mq.TLO.Me.Pet() ~= "NO PET" then
    mq.cmd("/pet get lost")
  end
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/dismisspet", createCommand, "Tells the bot to dismiss his/her pet.")

return execute
