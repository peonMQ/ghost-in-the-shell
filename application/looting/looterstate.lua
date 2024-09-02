local logger = require('knightlinc/Write')

---@class LooterState
---@field public Name string
local LooterState = {
  Name = "",
  __eq = function (self, looterState)
    return self.Name == looterState.Name
  end,
  __tostring = function (self)
    return self.Name
  end
}

---@param name string
---@return LooterState
function LooterState:new (name)
  self.__index = self
  local o = setmetatable({}, self)
  o.Name = name or logger.Fatal("Name is required for <LootState>")
  return o
end

---@class LooterStates
local LooterStates = {
  Idle = LooterState:new("IDLE"),
  Looting = LooterState:new("LOOTING"),
  Selling = LooterState:new("SELLING"),
}

return LooterStates