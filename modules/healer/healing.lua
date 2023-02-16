--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local plugin = require('utils/plugins')
local mqUtils = require('utils/mqhelpers')
local common = require('lib/common/common')
local state = require('lib/spells/state')
local numberUtils = require('lib/numberutils')
local config = require('modules/healer/config')
---@type Timer
local timer = require('lib/timer')


---@type Timer[]
local netbotTimers = {}

local function checkInterrupt(spellId)
  local target = mq.TLO.Target
  if not target() then
    state.interrupt()
  end

  if target.Type() == "Corpse" then
    state.interrupt()
  end

  local spell = mq.TLO.Spell(spellId)
  if numberUtils.IsLargerThan(target.Distance(), spell.Range()) then
    state.interrupt()
  end

  local emergencyHeal = config.MainTankEmergencyHeal
  if emergencyHeal and spell.ID == config.MainTankHeal.Id and config.MainTankHeal.Id ~= emergencyHeal.Id then
    if emergencyHeal:CanCastOnTarget(target --[[@as target]]) and mq.TLO.Me.Gem(emergencyHeal.Name)() then
      state.interrupt()
      emergencyHeal:Cast(checkInterrupt)
    end
  end
end

local function checkHealMainTank()
  if not config.MainTankHeal then
    return
  end

  local mainTank = common.GetMainTank()
  if not mainTank then
    return
  end

  if config.MainTankHeal:CanCastOnNetBot(mq.TLO.NetBots(mainTank) --[[@as netbot]]) and mqUtils.EnsureTarget(mq.TLO.NetBots(mainTank).ID())  then
    logger.Info("Healing maintank <%s>[%d]", mq.TLO.Target.Name(), mq.TLO.Target.PctHPs() or -100)
    config.MainTankHeal:Cast(checkInterrupt)
  end
end

local function checkHealGroup()
  local spell = config.GroupHeal
  if not spell then
    return
  end

  if mq.TLO.Group.Members() == 0 then
    logger.Debug("No group members.")
    return
  end

  local lowestMember = {
    id = 0,
    percentHP = 100
  }

  for i=1,mq.TLO.Group.Members() do
    local groupMember = mq.TLO.Group.Member(i) --[[@as groupmember]]
    if spell:CanCastOnGroupMember(groupMember) then
      if groupMember.PctHPs() < lowestMember.percentHP then
        lowestMember.id = groupMember.ID()
        lowestMember.percentHP = groupMember.PctHPs()
      end
    end
  end

  if lowestMember.id > 0 then
    if mqUtils.EnsureTarget(lowestMember.id) then
      spell:Cast(checkInterrupt)
    end
  end
end

local function checkHealNetBots()
  if plugin.IsLoaded("mq2netbots") == false then
    logger.Debug("mq2netbots is not loaded")
    return
  end

  local spell = config.NetbotsHeal
  if not spell then
    logger.Debug("No NetbotsHeal.")
    return
  end

  if mq.TLO.NetBots.Counts() < 2 then
    logger.Debug("No Nebots clients.")
    return
  end

  local lowestMember = {
    id = 0,
    percentHP = 100
  }

  for i=1,mq.TLO.NetBots.Counts() do
    local name = mq.TLO.NetBots.Client(i)()
    local netbot = mq.TLO.NetBots(name) --[[@as netbot]]
    if spell:CanCastOnNetBot(netbot) and (not netbotTimers[netbot.ID()] or netbotTimers[netbot.ID()]:IsComplete()) then
      if netbot.PctHPs() < lowestMember.percentHP then
        lowestMember.id = netbot.ID()
        lowestMember.percentHP = netbot.PctHPs()
      end
    end
  end

  if lowestMember.id > 0 then
    netbotTimers[lowestMember.id] = timer:new(2)
    if mqUtils.EnsureTarget(lowestMember.id) then
      logger.Info("Healing netbot <%s>[%d]", mq.TLO.Target.Name(), mq.TLO.Target.PctHPs())
      spell:Cast(checkInterrupt)
    end
  end
end

local function checkAEGroupHeal()
  if not config.AEGroupHeal then
    return
  end

  local minGroupHealCount = 3
  if mq.TLO.Group.Members() < minGroupHealCount then
    logger.Debug("No enough group members.")
    return
  end

  local spell = config.AEGroupHeal
  if not spell then
    logger.Debug("No AEGroupHeal.")
    return
  end

  if mq.TLO.Group.Injured(spell.HealPercent)() < 4 then
    logger.Debug("No enough group members.")
    return
  end

  
  local canHealCount = 0
  for i=1,mq.TLO.Group.Members() do
    local groupMember = mq.TLO.Group.Member(i) --[[@as groupmember]]
    if spell:CanCastOnGroupMember(groupMember) then
      if groupMember.Distance() < mq.TLO.Spell(spell.Id).AERange() then
        canHealCount = canHealCount + 1
      end
    end
  end

  if canHealCount >= minGroupHealCount then
    if mqUtils.EnsureTarget(mq.TLO.Me.ID()) then
      spell:Cast(checkInterrupt)
    end
  end
end

local function doHealing()
  checkHealMainTank()
  checkAEGroupHeal()
  checkHealGroup()
  checkHealNetBots()
end

return doHealing
