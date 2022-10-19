--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local mqUtils = require('utils/mq')
local plugin = require('utils/plugins')
local config = require('modules/buffer/config')
local state = require('lib/spells/state')

---@param spellId integer
local function checkInterrupt(spellId)
  local target = mq.TLO.Target
  if not target() then
    state.interrupt()
  end

  if target.Type() == "Corpse" then
    state.interrupt()
  end
end

---@param buffSpell BuffSpell
---@param targetId  integer
local function castBuff(buffSpell, targetId)
  if mqUtils.EnsureTarget(targetId) then
    if buffSpell:CanCastOnspawn(mq.TLO.Target) then
      logger.Info("Casting [%s] on <%s>", buffSpell.Name, mq.TLO.Target.Name())
      buffSpell:Cast(checkInterrupt)
    end
  end
end

local function checkSelfBuffs()
  local me = mq.TLO.Me

  for key, buffSpell in pairs(config.SelfBuffs) do
    if buffSpell:CanCast() then
      if not me.Buff(buffSpell.Name)() and (mq.TLO.Spell(buffSpell.Name).Stacks() or mq.TLO.Spell(buffSpell.Name).NewStacks()) then
        castBuff(buffSpell, me.ID())
        return;
      end
    end
  end
end

local function checkNetBotBuffs()
  if plugin.IsLoaded("mq2netbots") == false then
    logger.Debug("mq2netbots is not loaded")
    return
  end

  if mq.TLO.NetBots.Counts() < 2 then
    logger.Debug("Not enough Nebots clients, current: %d", mq.TLO.NetBots.Counts())
    return
  end

  for key, buffSpell in pairs(config.NetBotBuffs) do
    if buffSpell:CanCast() then
      local spell = mq.TLO.Spell(buffSpell.Id)
      if spell.TargetType() == "Single" then
        for i=1,mq.TLO.NetBots.Counts() do
          local name = mq.TLO.NetBots.Client(i)()
          local netbot = mq.TLO.NetBots(name) --[[@as netbot]]
          if netbot.InZone() == true and netbot.Class() ~= "NULL" and buffSpell:CanCastOnClass(netbot.Class.ShortName()) then
            if not netbot.Buff():find(""..buffSpell.Id) or netbot.Stacks(buffSpell.Id)() then
              castBuff(buffSpell, netbot.ID())
              return;
            end
          end
        end
      end
    end
  end
end

local function checkPetBuffs()
  local me = mq.TLO.Me
  for key, buffSpell in pairs(config.PetBuffs) do
    if buffSpell:CanCast() then
      local spell = mq.TLO.Spell(buffSpell.Id)
      if spell.TargetType() == "Single" and plugin.IsLoaded("mq2netbots") then
        for i=1,mq.TLO.NetBots.Counts() do
          local name = mq.TLO.NetBots.Client(i)()
          local netbot = mq.TLO.NetBots(name)
          if netbot.InZone() and netbot.PetID() > 0 then
            if netbot.PetBuff():find(""..buffSpell.Id) == 0 then
              castBuff(buffSpell, netbot.PetID())
              return;
            end
          end
        end
      elseif spell.TargetType() == "Pet" then
        if me.Pet.ID() > 0 and mq.TLO.Spell(buffSpell.Name).StacksPet() and not me.Pet.Buff(buffSpell.Name)() then
          castBuff(buffSpell, me.Pet.ID())
          return;
        end
      end
    end
  end
end

local function doBuffs()
  if not config.DoBuffsWithNpcInCamp then
    if mqUtils.NPCInRange() then
      logger.Debug("NPCs in camp, cannot buff.")
      return
    end
  end

  checkSelfBuffs()
  if not config.DoBuffsWithNpcInCamp then
    if mqUtils.NPCInRange() then
      logger.Debug("NPCs in camp, cannot buff.")
      return
    end
  end

  checkNetBotBuffs()
  if not config.DoBuffsWithNpcInCamp then
    if mqUtils.NPCInRange() then
      logger.Debug("NPCs in camp, cannot buff.")
      return
    end
  end

  checkPetBuffs()
end

return doBuffs