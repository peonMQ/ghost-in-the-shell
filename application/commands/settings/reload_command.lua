local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local settings = require('settings/settings')
local app_state = require('app_state')
local medley = require('application/medley/medley')
local binder = require('application/binder')

local function execute()
  logger.Info("Reloading bot settings...")
  broadcast.InfoAll("Reloading bot settings...")
  app_state.Pause()
  settings:ReloadSettings()
  medley.Reset()
  app_state.Activate()
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

mq.event("gainlevel", "You have gained a level!#*#", createCommand)
mq.event("scribed_spell", "You have finished scribing #*#", createCommand)
binder.Bind("/reloadsettings", createCommand, "Tells the bot to reload settings from file.")

return execute
