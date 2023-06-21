--- @type Mq
local mq = require 'mq'
local logger = require 'utils/logging'

---@param remainingDuration integer
local function cleanLowDurationBuffs(remainingDuration)
  local remainingTimer = remainingDuration or 10
  local me = mq.TLO.Me
  for i=1,15 do
    local buff = me.Buff(i)
    if buff() and buff.Duration.TotalSeconds() < remainingTimer then
      logger.Info("Removing buff <%s> from buffslot <%d> with remaining duration <%d>", buff(), i-1, buff.Duration.TotalSeconds())
      mq.cmdf("/notify BuffWindow Buff%d leftmouseup", i-1)
    end
  end
end

mq.unbind('/cleanbuffs')
mq.bind("/cleanbuffs", cleanLowDurationBuffs)