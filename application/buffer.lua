--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local plugin = require('utils/plugins')
local assist = require('core/assist')
local state = require('application/casting/casting_state')
local settings = require('settings/settings')

---@param spellId integer
local function checkInterrupt(spellId)
  local eqSpell = mq.TLO.Spell(spellId)
  if eqSpell.TargetType() == "Self" then
    return
  end

  local target = mq.TLO.Target
  if not target() then
    state.interrupt(spellId)
    return
  end

  if target.Type() == "Corpse" then
    state.interrupt(spellId)
    return
  end
end

---@param buffSpell BuffSpell|BuffItem
---@param targetId  integer
local function castBuff(buffSpell, targetId)
  local spawn = mq.TLO.Spawn(targetId)
  if spawn() then
    if buffSpell:CanCastOnSpawn(spawn --[[@as spawn]]) then
      if buffSpell.MQSpell.TargetType() ~= "Self" then
        spawn.DoTarget()
      end

      logger.Info("Casting [%s] on <%s>", buffSpell.Name, spawn.Name())
      buffSpell:Cast(checkInterrupt)
      return true
    end
  end

  return false
end

local function checkCombatBuffs()
  local me = mq.TLO.Me
  for _, buffSpell in pairs(settings.buffs.combat) do
    logger.Debug("Checking : %s %s %s", buffSpell.Name, buffSpell:CanCast(), buffSpell:WillStackOnMe())
    if buffSpell:CanCast() and buffSpell:WillStackOnMe() then
      castBuff(buffSpell, me.ID())
      return
    end
  end
end

---@return boolean
local function checkSelfBuffs()
  local me = mq.TLO.Me

  for _, buffSpell in pairs(settings.buffs.self) do
    if buffSpell:CanCast() and buffSpell:WillStackOnMe() then
      castBuff(buffSpell, me.ID())
      return true
    end
  end

  return false
end

---@return boolean
local function checkNetBotBuffs()
  if plugin.IsLoaded("mq2netbots") == false then
    logger.Debug("mq2netbots is not loaded")
    return false
  end

  if mq.TLO.NetBots.Counts() < 2 then
    logger.Debug("Not enough Nebots clients, current: %d", mq.TLO.NetBots.Counts())
    return false
  end

  for _, buffSpell in pairs(settings.buffs.request) do
    if buffSpell:CanCast() then
      local spell = buffSpell.MQSpell
      if spell.TargetType() == "Single" then
        for i=1,mq.TLO.NetBots.Counts() do
          local name = mq.TLO.NetBots.Client(i)()
          local netbot = mq.TLO.NetBots(name) --[[@as netbot]]
          if netbot.InZone() == true and netbot.Class() ~= "NULL" and buffSpell:CanCastOnClass(netbot.Class.ShortName()) then
            if buffSpell:WillStack(netbot) then
              local didCastBuff = castBuff(buffSpell, netbot.ID())
              if didCastBuff then
                return true
              end
            end
          end
        end
      end
    end
  end

  return false
end

---@return boolean
local function checkPetBuffs()
  if not settings.pet or not settings.pet.buffs then
    return false
  end

  local me = mq.TLO.Me
  for _, buffSpell in pairs(settings.pet.buffs) do
    if buffSpell:CanCast() then
      local spell = mq.TLO.Spell(buffSpell.Id)
      if spell.TargetType() == "Single" and plugin.IsLoaded("mq2netbots") then
        for i=1,mq.TLO.NetBots.Counts() do
          local name = mq.TLO.NetBots.Client(i)()
          local netbot = mq.TLO.NetBots(name)
          if netbot.InZone() and netbot.PetID() > 0 then
            if netbot.PetBuff():find(""..buffSpell.Id) == 0 then
              local didCastBuff = castBuff(buffSpell, netbot.PetID())
              if didCastBuff then
                return true
              end
            end
          end
        end
      elseif spell.TargetType() == "Pet" then
        if me.Pet.ID() > 0 and mq.TLO.Spell(buffSpell.Name).StacksPet() and not me.Pet.Buff(buffSpell.Name)() then
          local didCastBuff = castBuff(buffSpell, me.Pet.ID())
          if didCastBuff then
            return true
          end
        end
      end
    end
  end

  return false
end

---@return boolean
local function doBuffs()
  checkCombatBuffs()
  if assist.IsOrchestrator() then
    return false
  end

  if not settings.buffs.requestInCombat then
    if mqUtils.NPCInRange() then
      logger.Debug("NPCs in camp, cannot buff.")
      return false
    end
  end

  if checkSelfBuffs() then
    return true
  elseif checkNetBotBuffs() then
    return true
  elseif checkPetBuffs() then
    return true
  end

  return false
end

return doBuffs

-- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- https://gist.github.com/paulmoore/1429475
-- https://stackoverflow.com/questions/65961478/how-to-mimic-simple-inheritance-with-base-and-child-class-constructors-in-lua-t
-- https://www.tutorialspoint.com/lua/lua_object_oriented.htm

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff("id 647")

-- /lua parse mq.TLO.Me.FindBuff("id 647")

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff('spa charisma')