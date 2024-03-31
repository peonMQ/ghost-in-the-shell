local mq = require 'mq'
local mqutil = require 'utils/mqhelpers'
local item = require 'lib/spells/types/item'

---@class ConversionItem : Item
---@field public Id integer
---@field public Name string
---@field public ItemName string
---@field public StartManaPct number
---@field public StopHPPct number
local ConversionItem = item:base()

---@param itemName string
---@param start_mana_pct number
---@param stop_hp_pct number
---@return ConversionItem
function ConversionItem:new (itemName, start_mana_pct, stop_hp_pct)
  self.__index = self
  local o = setmetatable(item:new(itemName), self)
  o.StartManaPct = start_mana_pct or 0
  o.StopHPPct = stop_hp_pct or 100
  return o --[[@as ConversionItem]]
end

---@return boolean
function ConversionItem:CanCast()
  local me = mq.TLO.Me
  if me.Invis()
     or me.Casting()
     or me.PctHPs() < self.StopHPPct
     or mq.TLO.Window("SpellBookWnd").Open()
     or mq.TLO.Stick.Active()
     or mq.TLO.Navigation.Active() then
        return false
  end

  if me.PctMana() < self.StartManaPct and item.CanCast(self) then
    return true
  end

  return false
end

---@param cancelCallback? fun(spellId:integer)
---@return CastReturn
function ConversionItem:Cast(cancelCallback)
  return item.Cast(self, cancelCallback)
end

return ConversionItem
