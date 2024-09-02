local mqEvents = require('core/mqevent')
local MedleyStates = require('application/medley/medley_states')
local state = require('application/medley/state')

local function interruptedEvent()
  state.wasInterrupted = true
  state.castCompleteDue:Reset()
  state.medleyState = MedleyStates.IDLE
end

local function missedNote()
  state.wasInterrupted = true
  state.castCompleteDue:Reset()
  state.medleyState = MedleyStates.IDLE
end

local function recoverEvent()
  state.wasInterrupted = true
  state.castCompleteDue:Reset()
  state.medleyState = MedleyStates.IDLE
end

local function stunnedEvent()
  state.wasInterrupted = true
  state.medleyState = MedleyStates.IDLE
  state.castCompleteDue:Reset(10)
end


local events = {
  mqEvents:new("brd_interruptCasting", "Your casting has been interrupted#*#", interruptedEvent),
  mqEvents:new("brd_interruptSpell", "Your spell is interrupted#*#", interruptedEvent),
  mqEvents:new("brd_missednote", "You miss a note, bringing your#*#to a close!", missedNote),
  mqEvents:new("brd_recoverYou", "You haven't recovered yet...#*#", recoverEvent),
  mqEvents:new("brd_stunned", "You are stunned#*#", stunnedEvent),
  mqEvents:new("brd_stunnedCast", "You can't cast spells while stunned!#*#", stunnedEvent),
}

for _, value in ipairs(events) do
  value:Register()
end

return events