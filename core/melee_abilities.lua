--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')

--[[
  Kick - Regular attack, cannot damage magical mobs unless you are wearing magic boots.
  Round Kick - Magical attack. More damage. (This is the only one i'm slightly unsure on, i know it was coded as a magical attack in the original)
  Tiger Punch - Magical attack. Has chance to proc a +agro effect
  Tail Rake / Dragon punch - Magical attack. Has chance to proc a root effect on the mob
  Eagle Strike - Magical attack. Chance to proc an effect that can interrupt a spell
  Flying Kick - Magical attack. More damage, slightly longer reuse time as well if i remember correctly, but definitely your highest dps of the kicks.

  Keep tiger punch, tail rake / eagle strike, and flying kick at max skiill as you never know when you'll
  need them for the procs

  https://www.eqprogression.com/monk-class-basics-101/

  Feign Death – Maxes out at 200 skill. Max this out ASAP. Higher the skill level the lower the chance to fail.

  Mend – Allows you to recover HP 25% HP every 6 minutes. AA’s can cause it to critical heal for 50% HP. It can fail and can even do damage to you at lower skill levels. It maxes at 200, although from what I can remember it doesn’t fail once it’s at skill 100+. I recommend using Guild Master points to help level this up quickly.

  Kick DPS Skills – Kick/Round Kick/Flying Kick.  These share a timer.

  Punch DPS skills – Dragon Punch (Human) or Tail Rake (Iksar) /Tiger Claw/Eagle Strike. These share a timer.
]]

local kickAbilities = {"Flying Kick", "Round Kick", "Kick"}
local punchAbilities = {"Dragon Punch", "Tail Rake", "Tiger Claw", "Eagle Strike"}
local function doPriorityAbility(abilities)
  local me = mq.TLO.Me
  for _, ability in ipairs(abilities) do
    if me.SkillCap(ability)() and me.SkillCap(ability)() > 0 and me.AbilityReady(ability)() then
      mq.cmdf('/doability "%s"', ability)
      logger.Debug("Triggering ability <%s>", ability)
      return
    end
  end
end

local function doPunchesAndKicks()
  doPriorityAbility(punchAbilities)
  doPriorityAbility(kickAbilities)
end

local pickpockets = "Pick Pockets"
local function doPickPockets()
  local me = mq.TLO.Me
  local target = mq.TLO.Target
  if me.Heading.Degrees() - target.Heading.Degrees() < 45 then
    -- doRogueStrike()
    if me.AbilityReady(pickpockets)() then
      if mq.TLO.Me.Combat() then
        mq.cmd("/attack off")
      end
      mq.cmdf("/doability %s", pickpockets)
      logger.Debug("Triggering ability <%s>", pickpockets)
    end
  end
end

local hide = "Hide"
local function doEvade()
  local me = mq.TLO.Me
  local target = mq.TLO.Target
  -- doRogueStrike()
  if me.AbilityReady(hide)() then
    if mq.TLO.Me.Combat() then
      mq.cmd("/attack off")
    end
    doPickPockets()
    mq.cmdf("/doability %s", hide)
    logger.Debug("Triggering ability <%s>", hide)
    mq.cmd("/attack on")
  end
end

local backstab = "Backstab"
local function doBackStab()
  local me = mq.TLO.Me
  local target = mq.TLO.Target
  if me.Heading.Degrees() - target.Heading.Degrees() < 45 then
    -- doRogueStrike()
    if me.AbilityReady(backstab)() then
      mq.cmdf("/doability %s", backstab)
      logger.Debug("Triggering ability <%s>", backstab)
      doEvade()
    end
  end
end

local comatActions = {
  DoPunchesAndKicks = doPunchesAndKicks,
  DoBackStab = doBackStab
}

return comatActions