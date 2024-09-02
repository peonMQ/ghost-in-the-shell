local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')

local function execute(remainingDuration)
  local remainingTimer = remainingDuration or 10
  local me = mq.TLO.Me
  for i=1,mq.TLO.Me.MaxBuffSlots() do
    local buff = me.Buff(i)
    if buff() and buff.Duration.TotalSeconds() < remainingTimer then
      logger.Info("Removing buff <%s> from buffslot <%d> with remaining duration <%d>", buff(), i-1, buff.Duration.TotalSeconds())
      mq.cmdf("/notify BuffWindow Buff%d leftmouseup", i-1)
    end
  end
end

local function createCommand(remainingDuration)
    commandQueue.Enqueue(function() execute(remainingDuration) end)
end

binder.Bind("/cleanbuffs", createCommand, "Removes buss on toon with remainig duration less than 'duration' in seconds", 'duration')

return execute