local mq = require('mq')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local movement = require('core/movement')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')

local function execute()
  local agentOfChange = mq.getFilteredSpawns(function(spawn) return spawn.CleanName():lower() == "agent of change" and spawn.Distance() < 100 and spawn.LineOfSight() end)
  if next(agentOfChange) then
    local spawn = agentOfChange[1]
    if spawn and spawn() and mqUtils.EnsureTarget(spawn.ID()) then
      local target = mq.TLO.Target
      movement.MoveToLoc(target.X(), target.Y(), target.Z(), 20, 12)
      mq.cmd("/say ready")
    end
  else
    logger.Error("No \aoAgent of Change\ax found within range and in line of sight.")
  end
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/enterinstance", createCommand, "Tells the bot to navigate to the nearest 'agent of change' (range 100) and tell him he/she is 'ready'")
