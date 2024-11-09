local mq = require('mq')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local assist = require('core/assist')
local state = require('application/casting/casting_state')
local numberUtils = require('core/numbers')
local settings = require('settings/settings')

local function checkInterrupt(spellId)
  local target = mq.TLO.Target
  if not target() then
    state.interrupt(spellId)
    return
  end

  if target.Type() == "Corpse" then
    state.interrupt(spellId)
    return
  end

  local spell = mq.TLO.Spell(spellId)
  if numberUtils.IsLargerThan(target.Distance(), spell.Range()) then
    state.interrupt(spellId)
    return
  end
end

---@param netbot netbot
---@param counterType CounterTypes
---@return boolean
local function checkCure(netbot, counterType)
  local spell = settings.cures[counterType]
  if not spell then
    logger.Debug("Unable to cure netbot for '%s' <%s>[%d]", counterType, netbot.Name(), netbot.PctHPs())
    return false
  end

  if spell:CanCastOnNetBot(netbot) then
    if mqUtils.EnsureTarget(netbot.ID()) then
      logger.Info("Cure netbot with '%s' <%s>[%d]", spell.MQSpell.Name(), mq.TLO.Target.Name(), mq.TLO.Target.PctHPs())
      spell:Cast(checkInterrupt)
      return true
    end
  end

  logger.Info("Failed curing netbot with '%s' <%s>[%d]", spell.MQSpell.Name(), netbot.Name(), netbot.PctHPs())
  return false
end

---@return boolean
local function doCuring()
  if assist.IsOrchestrator() then
    return false
  end

  if mq.TLO.NetBots.Counts() < 1 then
    logger.Debug("No Nebots clients.")
    return false
  end

  for i=1,mq.TLO.NetBots.Counts() do
    local name = mq.TLO.NetBots.Client(i)()
    local netbot = mq.TLO.NetBots(name) --[[@as netbot]]
    if (tonumber(netbot.Poisoned()) or 0) > 0 and checkCure(netbot, 'poison') then
      return true
    elseif (tonumber(netbot.Diseased()) or 0) > 0 and checkCure(netbot, 'disease') then
      return true
    end
  end

  return false
end

return doCuring

