local logger = require 'utils/logging'

---@class LooterState
---@field public Name string
local LooterState = {Name = ""}

---@param name string
---@return LooterState
function LooterState:new (name)
  self.__index = self
  local o = setmetatable({}, self)
  o.Name = name or logger.Fatal("Name is required for <LootState>")
  return o
end

function LooterState:__eq(looterState)
  return self.Name == looterState.Name
end 

function LooterState:__tostring()
  return self.Name
end

---@class LooterStates
local LooterStates = {
  Idle = LooterState:new("IDLE"),
  Looting = LooterState:new("LOOTING"),
  Selling = LooterState:new("SELLING"),
}

return LooterStates