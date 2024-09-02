local mq = require('mq')
local logger = require('knightlinc/Write')
local plugins = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')

local function execute()
  mq.cmdf("/doortarget")
  mq.delay(50)
  mq.cmdf("/click left door")
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/clickdoor", createCommand, 'Tells the bot to click the nearest door if its within range of it.')

