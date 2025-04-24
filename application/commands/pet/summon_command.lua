local mq = require('mq')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local plugin = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local spells_pet = require('data/spells_pet')
local settings = require('settings/settings')
local pet_spell = require('core/casting/pets/petspell')
local item = require('core/casting/item')
local binder = require('application/binder')


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



local function mapSpellOrItem(spellName)
  if mq.TLO.FindItem("="..spellName)() then
    return item:new(spellName)
  end

  return pet_spell:new(spellName, settings.gems.pet or settings:GetDefaultGem(spellName), 15)
end

local function execute()
  local me = mq.TLO.Me
  if me.Pet() ~= "NO PET" then
    logger.Info("Already have an active pet <%s>.", me.Pet())
    return
  end

  local petSettings = settings.pet
  if not petSettings then
    logger.Debug("No pet settings configured.")
    return
  end

  local spellName, focusItem = spells_pet(settings.pet.type)
  if not spellName then
    logger.Debug("No pet spell found.")
    return
  end

  local petSpell = mapSpellOrItem(spellName)

  if not petSpell:CanCast() then
    logger.Info("Can not cast <%s>", petSpell.Name)
    return
  end

  local mainhand, offhand = equipSummonFocusItem(focusItem)

  petSpell:Cast()

  if mainhand then
    mq.cmdf('/exchange "%s" mainhand', mainhand)
    mq.delay(500)
  end

  if offhand then
    mq.cmdf('/exchange "%s" offhand', offhand)
    mq.delay(500)
  end

  if settings.pet.taunt then
    mq.cmd("/squelch /pet taunt on")
  else
    mq.cmd("/squelch /pet taunt off")
  end

  mq.cmd("/squelch /pet follow")
end

local function createCommand()
    commandQueue.Enqueue(function() execute() end)
end

binder.Bind("/summonpet", createCommand, "Tells the bot to summon his/her pet if its a pet class.")

return execute
