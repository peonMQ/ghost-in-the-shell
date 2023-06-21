--- @type Mq
local mq = require 'mq'
local mqutil = require 'utils/mqhelpers'
local configLoader = require 'utils/configloader'
---@type Spell
local spell = require 'lib/spells/types/spell'

---@class CommonConfig
local defaultConfig = {
  Spell = {},
  StartManaPct = 90,
  StopHPPct = 1
}

local next = next
local config = configLoader("general.mana.conversion", defaultConfig)
if next(config.Spell) then
  config.Spell = spell:new(config.Spell.Name, config.Spell.DefaultGem, 0)
else
  config.Spell = nil
end

local function doManaConversion()
  local conversionSpell = config.Spell
  if not conversionSpell then
    return
  end

  local me = mq.TLO.Me
  if me.Invis()
     or me.Casting()
     or me.PctHPs() < config.StopHPPct
     or mq.TLO.Window("SpellBookWnd").Open()
     or mq.TLO.Stick.Active()
     or mq.TLO.Navigation.Active() then
        return
  end

  if not mqutil.NPCInRange() and me.PctMana() < config.StartManaPct and conversionSpell:CanCast() then
    conversionSpell:Cast()
  elseif me.PctMana() < 2 then
    conversionSpell:Cast()
  end
end

return doManaConversion