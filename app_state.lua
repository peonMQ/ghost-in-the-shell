local mq = require('mq')
local logger = require('knightlinc/Write')
local BotState = require('bot_states')
local commandQueue  = require('application/command_queue')


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

function ApplicationState.IsPaused()
  return ApplicationState.RunningState == BotState.PAUSED
end

function ApplicationState.PerformActions()
  return ApplicationState.RunningState == BotState.ACTIVE
end

function ApplicationState.Activate()
  ApplicationState.RunningState = BotState.ACTIVE
end

function ApplicationState.CHAIN()
  ApplicationState.RunningState = BotState.CHAIN
end

function ApplicationState.Pause()
  ApplicationState.RunningState = BotState.PAUSED
  mq.cmd("/stopsong")
  mq.cmd("/stopcast")
  commandQueue.Clear()
end

---@param state string
local function toggle(state)
  local stateValue = tonumber(state)
  if not stateValue then
    logger.Error("Failed parsing BotState from %s", state)
    return
  end

  local newState = BotState(tonumber(state))
  if newState == BotState.PAUSED then
    ApplicationState.Pause()
  elseif newState == BotState.ACTIVE then
    ApplicationState.Activate()
  elseif newState == BotState.CHAIN then
    ApplicationState.CHAIN()
  end
end

mq.bind("/gitstoggle", toggle)

return ApplicationState