local mq = require('mq')
local logger = require('knightlinc/Write')
local mqutil = require('utils/mqhelpers')
local item = require('core/casting/item')
local Spell_SPA = require('data/spell_spa')

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
     or (me.PctHPs() < self.StopHPPct or not self:HasRunBuff())
     or mq.TLO.Window("SpellBookWnd").Open()
     or mq.TLO.Stick.Active()
     or mq.TLO.Navigation.Active() then
        return false
  end

   -- validate this wont kill us. https://discord.com/channels/511690098136580097/866047684242309140/1271477971575767111
  if self.MQSpell.HasSPA(0)() then
    for i = 1, self.MQSpell.NumEffects() + 1 do
        if self.MQSpell.Attrib(i)() == 0 then
            if mq.TLO.Me.CurrentHPs() + self.MQSpell.Base(i)() <= 0 then
              logger.Debug("\awUseItem(\ag%s\aw): \arTried to use item - but it would kill me!: %s! HPs: %d SpaHP: %d", self.Name, self.MQSpell.Name(), mq.TLO.Me.CurrentHPs(), self.MQSpell.Base(i)())
              return false
            end
        end
    end
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

function ConversionItem:HasRunBuff()
  local me = mq.TLO.Me
  for i=1,mq.TLO.Me.MaxBuffSlots() do
    local buff = me.Buff(i)
    if buff() then
      for i = 1, buff.NumEffects() + 1 do
        if buff.Attrib(i)() == Spell_SPA.SPA_STONESKIN then
          return true;
        end
      end
    end
  end
end

return ConversionItem
