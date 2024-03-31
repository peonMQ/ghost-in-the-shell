local mq = require 'mq'
local mqutil = require 'utils/mqhelpers'
local spell = require 'lib/spells/types/spell'

---@class ConversionSpell : Spell
---@field public Id integer
---@field public Name string
---@field public StartManaPct number
---@field public StopHPPct number
local ConversionSpell = spell:base()

---@param name string
---@param defaultGem integer
---@param start_mana_pct number
---@param stop_hp_pct number
---@return ConversionSpell
function ConversionSpell:new (name, defaultGem, start_mana_pct, stop_hp_pct)
  self.__index = self
  local o = setmetatable(spell:new(name, defaultGem, 0), self)
  o.StartManaPct = start_mana_pct or 0
  o.StopHPPct = stop_hp_pct or 100
  return o --[[@as ConversionSpell]]
end

---@return boolean
function ConversionSpell:CanCast()
  local me = mq.TLO.Me
  if me.Invis()
     or me.Casting()
     or me.PctHPs() < self.StopHPPct
     or mq.TLO.Window("SpellBookWnd").Open()
     or mq.TLO.Stick.Active()
     or mq.TLO.Navigation.Active() then
        return false
  end

  if not mqutil.NPCInRange() and me.PctMana() < self.StartManaPct and spell.CanCast(self) then
    return true
  elseif me.PctMana() < 2 then
    return true
  end

  return false
end

---@param cancelCallback? fun(spellId:integer)
---@return CastReturn
function ConversionSpell:Cast(cancelCallback)
  return spell.Cast(self, cancelCallback)
end

return ConversionSpell