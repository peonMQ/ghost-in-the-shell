local timer = require('core/timer')
local medley_states = require('application/medley/medley_states')
local loader = require('settings/loader')

---@alias MedleyProperties 'medleyState'|'currentSong'|'castCompleteDue'|'wasInterrupted'

---@class MedleyStateData
---@field medleyState MedleyStateEnum current medleystate
---@field currentSong Song|nil the current song playing
---@field castCompleteDue Timer timer of current casting
---@field wasInterrupted boolean was casting interrupted

---@class MedleyState : MedleyStateData
---@field Reset fun(self: MedleyState, property?: MedleyProperties) reset state to default state

---@class MedleyStateData
local defaultState = {
  medleyState = medley_states.UNINITALIZED,
  currentSong = nil,
  castCompleteDue = timer:new(0),
  wasInterrupted = false
}

local state = loader.Clone(defaultState) --[[@as MedleyState]]
-- state.medleyState = medley_states.UNINITALIZED
-- state.castCompleteDue = timer:new(0)

function state:Reset(property)
  for key, value in pairs(defaultState) do
    if not property or key == property then
      self[key] = value
    end
  end

  self.currentSong = nil
end

return state