local mq = require("mq")
local logger = require("knightlinc/Write")
local mqUtils = require 'utils/mqhelpers'
local moveUtils = require 'lib/moveutils'
local commandQueue  = require("application/command_queue")

local function execute()

  local agentOfChange = mq.getFilteredSpawns(function(spawn) return spawn.Name() == "Agent of Change" and spawn.Distance() < 50 and spawn.LineOfSight() end)
  if next(agentOfChange) then
    local spawn = agentOfChange[1]
    if spawn and spawn() and mqUtils.EnsureTarget(spawn.ID()) then
      local target = mq.TLO.Target
      moveUtils.MoveToLoc(target.X(), target.Y(), target.Z(), 20, 12)
      mq.cmd("/say ready")
    end
  end
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

mq.bind("/enterinstance", createCommand)
