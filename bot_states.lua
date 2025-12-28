
local Enum = require('utils/enum')

---@enum BotState
local BotState = Enum {
  ACTIVE = 1,
  PAUSED = 2,
  CHAIN  = 3,
}

return BotState