--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')
local plugin = require('utils/plugins')
local mqUtils = require('utils/mqhelpers')
local assist = require('core/assist')
local state = require('application/casting/casting_state')
local numberUtils = require('core/numbers')
local timer = require('core/timer')
local settings = require('settings/settings')


---@type Timer[]
local netbotTimers = {}

---@param spellId number
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

  local _, emergencyHeal = next(settings.heal.mt_emergency_heal or {})
  if emergencyHeal and spell.ID == emergencyHeal.Id and emergencyHeal.Id ~= emergencyHeal.Id then
    if emergencyHeal:CanCastOnTarget(target --[[@as target]]) and mq.TLO.Me.Gem(emergencyHeal.Name)() then
      state.interrupt(spellId)
      emergencyHeal:Cast(checkInterrupt)
      return
    end
  end
end

---@return boolean
local function checkHealMainTank()
  local _, main_tank_heal = next(settings.heal.mt_heal or {})
  if not main_tank_heal then
    return false
  end

  local mainTank = assist.GetMainTank()
  if not mainTank then
    return false
  end

  if main_tank_heal:CanCastOnNetBot(mq.TLO.NetBots(mainTank) --[[@as netbot]]) and mqUtils.EnsureTarget(mq.TLO.NetBots(mainTank).ID())  then
    logger.Info("Healing maintank <%s>[%d]", mq.TLO.Target.Name(), mq.TLO.Target.PctHPs() or -100)
    main_tank_heal:Cast(checkInterrupt)
    return true
  end

  return false
end

---@return boolean
local function checkHealGroup()
  local _, spell = next(settings.heal.default or {})
  if not spell then
    return false
  end

  if mq.TLO.Group.Members() == 0 then
    logger.Debug("No group members.")
    return false
  end

  local lowestMember = {
    id = 0,
    percentHP = 100
  }

  for i=1,mq.TLO.Group.Members() do
    local groupMember = mq.TLO.Group.Member(i) --[[@as groupmember]]
    if spell:CanCastOnGroupMember(groupMember) then
      if groupMember.PctHPs() and groupMember.PctHPs() < lowestMember.percentHP then
        lowestMember.id = groupMember.ID()
        lowestMember.percentHP = groupMember.PctHPs()
      end
    end
  end

  if lowestMember.id > 0 then
    if mqUtils.EnsureTarget(lowestMember.id) then
      spell:Cast(checkInterrupt)
      return true
    end
  end

  return false
end

---@return boolean
local function checkHealNetBots()
  if plugin.IsLoaded("mq2netbots") == false then
    logger.Debug("mq2netbots is not loaded")
    return false
  end

  local _, spell = next(settings.heal.default or {})
  if not spell then
    logger.Debug("No NetbotsHeal.")
    return false
  end

  if mq.TLO.NetBots.Counts() < 2 then
    logger.Debug("No Nebots clients.")
    return false
  end

  local lowestMember = {
    id = 0,
    percentHP = 100
  }

  for i=1,mq.TLO.NetBots.Counts() do
    local name = mq.TLO.NetBots.Client(i)()
    local netbot = mq.TLO.NetBots(name) --[[@as netbot]]
    if spell:CanCastOnNetBot(netbot, 15) and (not netbotTimers[netbot.ID()] or netbotTimers[netbot.ID()]:IsComplete()) then
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
      return true
    end
  end

  return false
end

---@return boolean
local function checkAEGroupHeal()
  local minGroupHealCount = 3
  if mq.TLO.Group.Members() < minGroupHealCount then
    logger.Debug("No enough group members %s/%s.", mq.TLO.Group.Members(), minGroupHealCount)
    return false
  end

  local _, spell = next(settings.heal.ae_group or {})
  if not spell then
    logger.Debug("No ae group heal spell.")
    return false
  end

  if not spell then
    logger.Debug("No ae_group heal.")
    return false
  end

  local minDamagedMembers = 3
  local damagedMembers = mq.TLO.Group.Injured(spell.HealPercent)()
  if damagedMembers < minDamagedMembers then
    logger.Debug("No enough damaged group members %s/%s.", damagedMembers, minDamagedMembers)
    return false
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
      return true
    end
  end

  return false
end

---@return boolean
local function checkHotNetBots()
  if plugin.IsLoaded("mq2netbots") == false then
    logger.Debug("mq2netbots is not loaded")
    return false
  end

  local _, spell = next(settings.heal.hot or {})
  if not spell then
    logger.Debug("No hot heal.")
    return false
  end

  if mq.TLO.NetBots.Counts() < 1 then
    logger.Debug("No Nebots clients.")
    return false
  end

  local lowestMember = {
    id = 0,
    percentHP = 100
  }

  for i=1,mq.TLO.NetBots.Counts() do
    local name = mq.TLO.NetBots.Client(i)()
    local netbot = mq.TLO.NetBots(name) --[[@as netbot]]
    if spell:CanCastOnNetBot(netbot) and spell:WillStack(netbot) and (not netbotTimers[netbot.ID()] or netbotTimers[netbot.ID()]:IsComplete()) then
      if netbot.PctHPs() < lowestMember.percentHP then
        lowestMember.id = netbot.ID()
        lowestMember.percentHP = netbot.PctHPs()
      end
    end
  end

  if lowestMember.id > 0 then
    netbotTimers[lowestMember.id] = timer:new(2)
    if mqUtils.EnsureTarget(lowestMember.id) then
      logger.Info("Hot netbot '%s' <%s>[%d]", spell.MQSpell.Name(), mq.TLO.Target.Name(), mq.TLO.Target.PctHPs())
      spell:Cast(checkInterrupt)
      return true
    end
  end

  return false
end

---@return boolean
local function doHealing()
  if assist.IsOrchestrator() then
    return false
  end

  if checkHealMainTank() then
    return true
  elseif checkAEGroupHeal() then
    return true
  elseif checkHealGroup() then
    return true
  elseif checkHealNetBots() then
    return true
  elseif checkHotNetBots() then
    return true
  end

  return false
end

return doHealing


-- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- https://gist.github.com/paulmoore/1429475
-- https://stackoverflow.com/questions/65961478/how-to-mimic-simple-inheritance-with-base-and-child-class-constructors-in-lua-t
-- https://www.tutorialspoint.com/lua/lua_object_oriented.htm

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff("id 647")

-- /lua parse mq.TLO.Me.FindBuff("id 647")

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff('spa charisma')