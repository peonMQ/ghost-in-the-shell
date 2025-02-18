local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local memorize_command  = require('application/commands/memorize_command')
local loot_corpse_command  = require('application/commands/wait4rez/loot_corpse_command')
local binder = require('application/binder')


local function waitToZone()
	logger.Debug("Waiting to zone.")
  local me = mq.TLO.Me.Name()
  repeat
    mq.delay(100)
  until not mq.TLO.Spawn(me.."'s").ID()

  mq.delay(500)
  logger.Debug("Completed zoneing to corpse.")
end

local function waitToZoneToCorpse()
	logger.Debug("Waiting to zone.")
  local me = mq.TLO.Me.Name()
  repeat
    mq.delay(100)
  until mq.TLO.Spawn(me.."'s").ID()

  mq.delay(500)
  logger.Debug("Completed zoneing to corpse.")
end

local function execute()
  broadcast.FailAll("%s died, awaiting rez.", mq.TLO.Me.Name())
  mq.cmd("/beep")
  -- waitToZone()
  mq.cmd("/consent guild")
  -- memorize_command()
  broadcast.WarnAll("Ready for rezz.")
  repeat
    mq.delay(10)
  until mq.TLO.Window("ConfirmationDialogBox").Open() and mq.TLO.Window("ConfirmationDialogBox").Child("cd_textoutput").Text():find("percent)")

  mq.cmd("/nomodkey /notify ConfirmationDialogBox Yes_Button leftmouseup")
  waitToZoneToCorpse()
  broadcast.SuccessAll("Ressurected, ready to loot corpse.")
  loot_corpse_command()
  memorize_command()
end

local function createCommand()
  commandQueue.Clear()
  commandQueue.Enqueue(function() execute() end)
end

mq.event("slain", "You have been slain by #*#", createCommand)
mq.event("died", "You died.", createCommand)
binder.Bind("/youdied", createCommand, "Tells bot it died and needs to wait for rezz")
