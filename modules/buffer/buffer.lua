--- @type Mq
local mq = require 'mq'
local logger = require("knightlinc/Write")
local mqUtils = require 'utils/mqhelpers'
local plugin = require 'utils/plugins'
local state = require 'lib/spells/state'
local settings = require 'settings/settings'

local SPA_MOVEMENT_RATE = 3
---@param buffSpell spell
---@param currentBuff spell
---@return boolean
local function willStack(buffSpell, currentBuff)
  if buffSpell() and not mq.TLO.Spell(buffSpell.ID()).WillStack(currentBuff.Name())() then
    return false
  end

  if buffSpell.HasSPA(SPA_MOVEMENT_RATE)() then
    for i=1,buffSpell.NumEffects() do
      local buffspellSPA = buffSpell.Attrib(i)()
      if buffspellSPA == SPA_MOVEMENT_RATE and currentBuff.Attrib(i)() == buffspellSPA then
        if buffSpell.Base(i)() > 0 and currentBuff.Base(i)() < 0 then
          return false
        end
      end
    end
  end

  return true
end

---@param buffSpell spell
---@return boolean
local function willStackOnMe(buffSpell)
  for i=1,mq.TLO.Me.MaxBuffSlots() do
    local currentBuff = mq.TLO.Me.Buff(i) --[[@as buff]]
    if currentBuff() and not willStack(buffSpell, currentBuff) then
      return false
    end
  end

  return true
end

---@param spellId integer
local function checkInterrupt(spellId)
  local target = mq.TLO.Target
  if not target() then
    state.interrupt()
    return
  end

  if target.Type() == "Corpse" then
    state.interrupt()
    return
  end
end

---@param buffSpell BuffSpell
---@param targetId  integer
local function castBuff(buffSpell, targetId)
  local spawn = mq.TLO.Spawn(targetId)
  if spawn() then
    if buffSpell:CanCastOnspawn(spawn --[[@as spawn]]) and mqUtils.EnsureTarget(targetId)then
      logger.Info("Casting [%s] on <%s>", buffSpell.Name, mq.TLO.Target.Name())
      buffSpell:Cast(checkInterrupt)
      return true
    end
  end

  return false
end

local function checkSelfBuffs()
  local me = mq.TLO.Me

  for _, buffSpell in pairs(settings.buffs.self) do
    if buffSpell:CanCast() then
      if (not me.Buff(buffSpell.Name)() and not me.Song(buffSpell.Name)()) and (willStackOnMe(buffSpell.MQSpell)) then
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
                return
              end
            end
          end
        end
      end
    end
  end
end

local function checkPetBuffs()
  if not settings.pet or not settings.pet.buffs then
    return
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
                return
              end
            end
          end
        end
      elseif spell.TargetType() == "Pet" then
        if me.Pet.ID() > 0 and mq.TLO.Spell(buffSpell.Name).StacksPet() and not me.Pet.Buff(buffSpell.Name)() then
          local didCastBuff = castBuff(buffSpell, me.Pet.ID())
          if didCastBuff then
            return
          end
        end
      end
    end
  end
end

local function doBuffs()
  if not settings.buffs.requestInCombat then
    if mqUtils.NPCInRange() then
      logger.Debug("NPCs in camp, cannot buff.")
      return
    end
  end

  checkSelfBuffs()
  checkNetBotBuffs()
  checkPetBuffs()
end

return doBuffs

-- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- https://gist.github.com/paulmoore/1429475
-- https://stackoverflow.com/questions/65961478/how-to-mimic-simple-inheritance-with-base-and-child-class-constructors-in-lua-t
-- https://www.tutorialspoint.com/lua/lua_object_oriented.htm

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff("id 647")

-- /lua parse mq.TLO.Me.FindBuff("id 647")

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff('spa charisma')