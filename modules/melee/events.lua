--- @type Mq
local mq = require 'mq'
local logger = require 'utils/logging'
local state = require 'modules/melee/state'
--- @type MQEvent
local mqEvents = require 'lib/mqevent'

local tooFarAWay = mqEvents:new("tooFarAway", "Your target is too far away, get closer!", function() end)

local function enragedOnEvent(enragedMobName)
  if mq.TLO.Target.ID() == mq.TLO.Spawn(enragedMobName).ID() then
    if mq.TLO.Me.Combat() then
      mq.cmd("/attack off")
      state.enraged = true
    end
  end
end

local function enragedOnOff(enragedMobName)
  if mq.TLO.Target.ID() == mq.TLO.Spawn(enragedMobName).ID() then
    if mq.TLO.Me.Combat() then
      mq.cmd("/attack on")
      state.enraged = false
    end
  end
end

local function toFarAwayEvent()
  if mq.TLO.Me.Combat() then
    tooFarAWay:Flush()
    mq.cmd("/squelch /face fast")
    local stickDistance = math.floor(mq.TLO.Stick.Distance()*0.75)
    if mq.TLO.Stick.MoveBehind() then
      mq.cmdf("/stick id %d moveback behind %d uw", mq.TLO.Target.ID(), stickDistance)
    else
      mq.cmdf("/stick id %d moveback front %d uw", mq.TLO.Target.ID(), stickDistance)
    end
  end
end

tooFarAWay.CallBack = toFarAwayEvent

local events = {
  mqEvents:new("enrageOn", "#1# has become ENRAGED.", enragedOnEvent),
  mqEvents:new("enrageOff", "#1# is no longer enraged.", enragedOnOff),
  tooFarAWay
}

for key, value in pairs(events) do
  value:Register()
end

return events