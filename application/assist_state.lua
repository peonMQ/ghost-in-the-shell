local loader = require 'settings/loader'

---@alias AssistMode 'normal'|'powerlevel'
---@alias CrowdControlMode 'single_mez'|'ae_mez'|'unresistable_mez'|nil

---@class AssistStateData
---@field mode AssistMode what kind of assist mode are we in
---@field spell_set string the nuke spell_set
---@field pbaoe_active boolean toggle pbaoe
---@field crowd_control_mode CrowdControlMode auto mezz mode
---@field current_pet_target_id number
---@field enraged boolean

---@class AssistState : AssistStateData
---@field Reset fun(self: AssistState, property?: string) reset state to default state

---@class AssistStateData
local defaultState = {
  mode = 'normal',
  spell_set = 'main',
  pbaoe_active = false,
  mezz_mode = nil,
  current_pet_target_id = 0,
  enraged = false
}

local state = loader.Clone(defaultState) --[[@as AssistState]]
function state:Reset(property)
  for key, value in pairs(defaultState) do
    if not property or key == property then
      self[key] = value
    end
  end
end

return state