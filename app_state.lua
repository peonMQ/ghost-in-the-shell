local mq = require 'mq'

---@enum BotState
local BotState = {
  ACTIVE = 0,
  PAUSED = 1
}

local ApplicationState =  {
  RunningState = BotState.PAUSED
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

return ApplicationState