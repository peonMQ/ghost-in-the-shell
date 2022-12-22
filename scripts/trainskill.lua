--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local mqUtils = require('utils/mqhelper')

local args = {...}
local function Main()
  local ability  = args[0] --[[@as string]]

  if mq.TLO.Me.Skill(ability)() == false then
    logger.Info('You do not have the skill <%s>', ability)
    mq.exit()
  end

  if mq.TLO.Me.Ability(ability)() == false then
    logger.Info('Ability is not mapped to action button <%s>', ability)
    mq.exit()
  end

  while mq.TLO.Me.Skill(ability)() ~= mq.TLO.Skill(ability).SkillCap() do
    if mq.TLO.Me.Sneaking() then
        mq.cmd('/doability Sneak')
    end

    if mq.TLO.Me.AbilityReady(ability)() then
        mq.cmdf('/doability "%s"', ability)
        mq.delay(2)
    end

    mqUtils.ClearCursor()

    if mq.TLO.Me.Feigning() then
        mq.cmd('/stand')
    end
  end

  logger.Info('You maxed the skill <%s>', ability)
end

Main()