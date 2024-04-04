local mq = require 'mq'
local logger = require("knightlinc/Write")
local common = require 'lib/common/common'
local assist_state = require 'application/assist_state'
local mqEvents = require 'lib/mqevent'

local tooFarAWay = mqEvents:new("tooFarAway", "Your target is too far away, get closer!", function() end)

local function enragedOnEvent(enragedMobName)
  if mq.TLO.Target.ID() == mq.TLO.Spawn(enragedMobName).ID() then
    if mq.TLO.Me.Combat() then
      mq.cmd("/attack off")
      assist_state.enraged = true
    end
  end
end

local function enragedOnOff(enragedMobName)
  if mq.TLO.Target.ID() == mq.TLO.Spawn(enragedMobName).ID() then
    if mq.TLO.Me.Combat() then
      mq.cmd("/attack on")
      assist_state.enraged = false
    end
  end
end

local function toFarAwayEvent()
  if mq.TLO.Me.Combat() then
    tooFarAWay:Flush()
    if common.IsOrchestrator() then
      return
    end

    mq.cmd("/squelch /face fast")
    local stickDistance = math.floor(mq.TLO.Stick.Distance()*0.75)
    if mq.TLO.Stick.MoveBehind() then
      mq.cmdf("/stick id %d moveback behind %d uw", mq.TLO.Target.ID(), stickDistance)
    else
      mq.cmdf("/stick id %d moveback front %d uw", mq.TLO.Target.ID(), stickDistance)
    end
  end
end

local events = {
  mqEvents:new("enrageOn", "#1# has become ENRAGED.", enragedOnEvent),
  mqEvents:new("enrageOff", "#1# is no longer enraged.", enragedOnOff),
  mqEvents:new("toFarAway", "Your target is too far away, get closer!", toFarAwayEvent)
}

for key, value in pairs(events) do
  value:Register()
end

return events