--- @type Mq
local mq = require 'mq'
local logger = require 'utils/logging'
local mqUtils = require 'utils/mqhelpers'
local common = require 'lib/common/common'
local commonConfig = require 'lib/common/config'
local settings = require 'settings/settings'
local state = require 'modules/melee/state'
local events = require 'modules/melee/events'

local function doEvents()
  for key, value in pairs(events) do
    value:DoEvent()
  end
  mq.delay(100)
end

-- | https://www.mmobugs.com/wiki/index.php/MQ2MoveUtils:v11_FAQ
-- | https://www.redguides.com/community/threads/mq2moveutils-question.70706/
-- | https://www.redguides.com/community/threads/mq2-vanilla-max-melee-range.54990/
-- | only snaproll for rogues, others can start DPS right away?

---@param target target
---@param modifier number
local function stickToTarget(target, modifier)
  local stick = mq.TLO.Stick
  if stick.Active() and stick.StickTarget() == target.ID() then
    return
  end

  mq.cmd("/squelch /face fast")
  if common.GetMainTank() == mq.TLO.Me.Name() or common.AmIOfftank() then
    mq.cmdf("/squelch /stick id %d front 4 uw", target.ID())
    mq.delay("5s", function() return stick.Stopped() end)
  else
    local stickDistance = math.floor(mq.TLO.Spawn("id "..target.ID()).MaxRangeTo()*modifier)
    stickDistance = math.min(stickDistance, 25)
    mq.cmdf("/squelch /stick id %d snaproll %d uw", target.ID(), stickDistance)
    mq.delay("5s", function() return stick.Stopped() end)
    mq.cmdf("/squelch /stick id %d moveback behind %d uw", target.ID(), stickDistance)
  end
end

---@param meleeAbilityCallback? fun()
local function doMeleeDps(meleeAbilityCallback)
  local me = mq.TLO.Me

  if settings.assist.type ~= 'melee' then
    return
  end

  doEvents()
  if state.enraged and me.Combat() then
    mq.cmd("/attack off")
    logger.Debug("Enraged, attack off")
    return
  end

  local target = mq.TLO.Target
  if me.Combat() then
    if target() and target.Type() ~= "Corpse" and target.Type() ~= "PC" then
      if meleeAbilityCallback then
        meleeAbilityCallback()
      end

      return
    else
      mq.cmd("/attack off")
      if mq.TLO.Stick.Active() then
        mq.cmd("/stick off")
      end
      state.enraged = false
      return
    end
  end

  local mainAssist = common.GetMainAssist()
  if not mainAssist then
    if me.Combat() then
      mq.cmd("/attack off")
    end
    if mq.TLO.Stick.Active() then
      mq.cmd("/stick off")
    end
    state.enraged = false
    logger.Debug("Mainassist not found")
    return
  end

  local netbot = mq.TLO.NetBots(mainAssist)
  if netbot.TargetID() == "NULL" then
    return
  end

  local targetSpawn = mq.TLO.Spawn(netbot.TargetID())
  local isNPC = targetSpawn.Type() == "NPC"
  local isPet = targetSpawn.Type() == "Pet"
  local hasLineOfSight = targetSpawn.LineOfSight()
  local targetHP = netbot.TargetHP()

  if (not isNPC and not isPet)
      or (targetHP > 0 and targetHP > settings.assist.engage_at)
      or not hasLineOfSight then
    logger.Debug("Mainassist target is not valid")
    return
  end

  if mqUtils.EnsureTarget(netbot.TargetID()) then
    if not mq.TLO.Stick.Active() or mq.TLO.Stick.StickTarget() ~= netbot.TargetID() then
      logger.Debug("Attempting to stick to target")
      stickToTarget(mq.TLO.Target --[[@as target]], 0.75)
    end

    mq.cmd("/attack on")
  end
end

return doMeleeDps