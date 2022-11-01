--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local plugin = require('utils/plugins')
local mqUtils = require('utils/mq')
local common = require('lib/common/common')
local config = require('modules/pet/config')
local petstates = require('modules/pet/types/petstate')
require('modules/pet/weaponize')
---@type PetSpell
local petSpell = require('modules/pet/types/petspell')

local state = petstates.Idle

local function equipSummonFocusItem(petSummonFocusItem)
  if not petSummonFocusItem or petSummonFocusItem == "" then
    return nil, nil
  end

  if plugin.IsLoaded("mq2exchange") == false then
    return nil, nil
  end

  if not mq.TLO.FindItem("="..petSummonFocusItem)() then
    return nil, nil
  end

  local currentMainhand = mq.TLO.Me.Inventory("mainhand")()
  local currentOffhand = mq.TLO.Me.Inventory("offhand")() -- or slot 14

  if currentOffhand then
    mq.cmd("/unequip offhand")
    mq.delay(250)
    mqUtils.ClearCursor()
  end

  mq.cmdf('/exchange "%s" mainhand', petSummonFocusItem)
  mq.delay(500)

  if mq.TLO.Me.Inventory("mainhand")() ~= petSummonFocusItem then
    logger.Debug("Unable to equip <%s>.", petSummonFocusItem)
  end

  return currentMainhand, currentOffhand
end

local function summonPet()
  local me = mq.TLO.Me
  if me.Pet() ~= "NO PET" then
    logger.Info("Already have an active pet <%s>", me.Pet())
    state = petstates.Idle
    return
  end

  local petSpell = config.PetSpell
  if not petSpell then
    logger.Debug("No pet spell configured")
    state = petstates.Idle
    return
  end

  if not petSpell:CanCast() then
    logger.Info("Cannott cast <%s>", petSpell.Name)
    state = petstates.Idle
    return
  end

  local mainhand, offhand = equipSummonFocusItem(petSpell.FocusItem)

  petSpell:Cast()

  if mainhand then
    mq.cmdf('/exchange "%s" mainhand', mainhand)
    mq.delay(500)
  end

  if offhand then
    mq.cmdf('/exchange "%s" offhand', offhand)
    mq.delay(500)
  end

  state = petstates.Idle
end

local function disbandPet()
  if mq.TLO.Me.Pet() then
    mq.cmd("/pet get lost")
  end
end

local function setActivePetSpell(newPetSpell, newSummonFocusItem)
  if not newPetSpell then
    logger.Warn("New pet spell is <nil>")
    return
  end

  local petSpell = config.PetSpell
  if not mq.TLO.Me.Book(newPetSpell)() then
    mq.cmd("/beep")
    logger.Error("You do not know the spell <%s>.", newPetSpell)
    return
  else
    config.PetSpell = petSpell:new(newPetSpell, petSpell.DefaultGem, petSpell.MinManaPercent, petSpell.GiveUpTimer, petSpell.FocusItem)
    logger.Info("New pet spell the spell <%s>.", newPetSpell)
  end

  if not newSummonFocusItem then
    return
  end

  if newSummonFocusItem and not mq.TLO.FindItem("="..newSummonFocusItem)() then
    mq.cmd("/beep")
    logger.Error("You do not have the focus item <%s> on your character..", newSummonFocusItem)
  else
    config.PetSpell = petSpell:new(petSpell.Name, petSpell.DefaultGem, petSpell.MinManaPercent, petSpell.GiveUpTimer, newSummonFocusItem)
    logger.Info("New pet focus item <%s>.", newSummonFocusItem)
  end
end


local function doPet()
  if state == petstates.SummonPet then
    summonPet()
  end

  if not mq.TLO.Me.Pet.ID() or mq.TLO.Me.Pet.ID() == 0 then
    return
  end

  local query = "id "..config.CurrentPetTarget
  if config.CurrentPetTarget > 0 and (not mq.TLO.SpawnCount(query)() or mq.TLO.Spawn(query).Type() == "Corpse") then
    mq.cmd("/pet back off")
    config.CurrentPetTarget = 0
  elseif config.CurrentPetTarget > 0 then
    logger.Debug("Pet has target and hopefully attacking")
    return
  end

  local mainAssist = common.GetMainAssist()
  if not mainAssist then
    return
  end

  local netbot = mq.TLO.NetBots(mainAssist)
  local targetId = netbot.TargetID()
  if not targetId then
    return
  end

  local targetSpawn = mq.TLO.Spawn(targetId)
  local isNPC = targetSpawn.Type() == "NPC"
  local isPet = targetSpawn.Type() == "Pet"
  local hasLineOfSight = targetSpawn.LineOfSight()
  local targetHP = netbot.TargetHP()

  if (not isNPC and not isPet)
     or (targetHP > 0 and targetHP > config.PetAssistPercent)
     or not hasLineOfSight
     or targetSpawn.Distance() > 100 then
      return
  end

  if mqUtils.EnsureTarget(targetId) then
    config.CurrentPetTarget = targetId
    mq.cmd("/pet back off")
    mq.delay(5)
    mq.cmd("/pet attack")
    mq.delay(5)
    mq.cmd("/pet attack")
  end
end

local function createAliases()
  mq.unbind('/setactivepet')
  mq.unbind('/summonpet')
  mq.unbind('/disbandpet')
  mq.bind("/setactivepet", setActivePetSpell)
  mq.bind("/summonpet", function() state = petstates.SummonPet end)
  mq.bind("/disbandpet", disbandPet)
end

createAliases()

return doPet

-- /setactivepet "Greater Vocaration: Earth" "Staff of Elemental Mastery: Earth"

-- /lua parse mq.TLO.Me.Gem("Greater Vocaration: Earth")
-- /memspell 1 "Greater Vocaration: Earth"
-- 8 is not a valid slot for this container.