local loader = require 'settings/loader'

---@alias FollowMode 'nav'|'actor'

---@class FollowStateData
---@field mode FollowMode what kind of follow mode are we in
---@field spawn_id number|nil

---@class FollowState : FollowStateData
---@field Reset fun(self: FollowStateData, property?: string) reset state to default state

---@class FollowStateData
local defaultState = {
  mode = 'nav',
  spawn_id = nil
}

local state = loader.Clone(defaultState) --[[@as FollowState]]
function state:Reset(property)
  for key, value in pairs(defaultState) do
    if not property or key == property then
      self[key] = value
    end
  end
end

return state