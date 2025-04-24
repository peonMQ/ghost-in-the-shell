--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local assist = require('core/assist')
local settings = require('settings/settings')
local events = require('application/meleeing/events')
local assist_state = require('application/assist_state')

local function doEvents()
  mq.doevents()
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

  logger.Debug("Attempting to stick to target")
  mq.cmd("/squelch /face fast")
  local stickDistance = math.floor(mq.TLO.Spawn("id "..target.ID()).MaxRangeTo()*modifier)
  if assist.GetMainTank() == mq.TLO.Me.Name() or assist.AmIOfftank() then
    mq.cmdf("/squelch /stick id %d front 4 uw", target.ID())
    mq.delay("5s", function() return stick.Stopped() end)
  else
    stickDistance = math.min(stickDistance, 25)
    mq.cmdf("/squelch /stick id %d snaproll %d uw", target.ID(), stickDistance)
    mq.delay("5s", function() return stick.Stopped() end)
    mq.cmdf("/squelch /stick id %d moveback behind %d uw", target.ID(), stickDistance)
  end
  mq.delay("5s", function() return not mq.TLO.Spawn("id "..target.ID())() or mq.TLO.Spawn("id "..target.ID()).Distance() <= stickDistance end)
end

---@param me character
local function reset(me)
  if me.Combat() then
    mq.cmd("/attack off")
  end

  if mq.TLO.Stick.Active() then
    mq.cmd("/stick off")
  end

  assist_state.enraged = false
end

---@param meleeAbilityCallback? fun()
---@return boolean
local function doMeleeDps(meleeAbilityCallback)
  if assist.IsOrchestrator() then
    if mq.TLO.Stick.Active() then
      mq.cmd("/stick off")
    end

    return false
  end

  if settings.assist.type ~= 'melee' then
    return false
  end

  local me = mq.TLO.Me --[[@as character]]
  if assist_state.current_target_id == 0 then
    reset(me)
    return false
  end

  doEvents()
  if assist_state.enraged then
    if me.Combat() then
      logger.Debug("Enraged, attack off")
      mq.cmd("/attack off")
    end

    return false
  end

  if mqUtils.EnsureTarget(assist_state.current_target_id) then
    local target = mq.TLO.Target
    if me.Combat() then
      if target() and target.Type() ~= "Corpse" then
        if meleeAbilityCallback then
          meleeAbilityCallback()
        end

        return false
      else
        reset(me)
        return false
      end
    end

    stickToTarget(mq.TLO.Target --[[@as target]], 0.75)
    if not me.Combat() then
      mq.cmd("/attack on")
    end
  end

  return false
end

return doMeleeDps