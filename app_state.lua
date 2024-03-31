local mq = require 'mq'
local logger = require("knightlinc/Write")
local commandQueue  = require("application/command_queue")

---@enum BotState
local BotState = {
  ACTIVE = 0,
  PAUSED = 1
}

local ApplicationState =  {
  RunningState = BotState.ACTIVE
}

function ApplicationState.IsActive()
  return ApplicationState.RunningState == BotState.ACTIVE
end

function ApplicationState.Activate()
  ApplicationState.RunningState = BotState.ACTIVE
end

function ApplicationState.Pause()
  ApplicationState.RunningState = BotState.PAUSED
end

local function toggle(state)
  if tonumber(state) == BotState.PAUSED then
    ApplicationState.Pause()
    mq.cmd("/stopsong")
    mq.cmd("/stopcast")
    commandQueue.Clear()
  elseif tonumber(state) == BotState.ACTIVE then
    ApplicationState.Activate()
  end
end

mq.bind("/gitstoggle", toggle)

return ApplicationState