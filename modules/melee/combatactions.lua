--- @type Mq
local mq = require('mq')

local function doPunchesAndKicks()
  local me = mq.TLO.Me

  if me.AbilityReady("Tiger Claw")() then
    mq.cmd('/doability "Tiger Claw"')
  end

  if me.AbilityReady("Flying Kick")() then
    mq.cmd('/doability "Flying Kick"')
  end
end

local function doBackStab()
  local me = mq.TLO.Me
  local target = mq.TLO.Target
  if me.Heading.Degrees() - target.Heading.Degrees() < 45 then
    -- doRogueStrike()
    if me.AbilityReady("Backstab")() then
      mq.cmd("/doability Backstab")
    end
  end
end

local comatActions = {
  DoPunchesAndKicks = doPunchesAndKicks,
  DoBackStab = doBackStab
}

return comatActions