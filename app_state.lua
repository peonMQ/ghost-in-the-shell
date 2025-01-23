local mq = require('mq')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')

---@enum BotState
local BotState = {
  ACTIVE = 1,
  PAUSED = 2,
  CHAIN = 3
}

---@class ApplicationState
---@field RunningState BotState
---@field CampLoc ImVec4 | nil
local ApplicationState =  {
  RunningState = BotState.ACTIVE,
  CampLoc = nil
}

function ApplicationState.IsActive()
  return ApplicationState.RunningState == BotState.ACTIVE
end

function ApplicationState.PerformActions()
  return ApplicationState.RunningState == BotState.ACTIVE
end

function ApplicationState.Activate()
  ApplicationState.RunningState = BotState.ACTIVE
end

function ApplicationState.Pause()
  ApplicationState.RunningState = BotState.PAUSED
  mq.cmd("/stopsong")
  mq.cmd("/stopcast")
  commandQueue.Clear()
end

local function toggle(state)
  if tonumber(state) == BotState.PAUSED then
    ApplicationState.Pause()
  elseif tonumber(state) == BotState.ACTIVE then
    ApplicationState.Activate()
  end
end

mq.bind("/gitstoggle", toggle)

return ApplicationState