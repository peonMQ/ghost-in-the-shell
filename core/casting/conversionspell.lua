local mq = require('mq')
local logger = require('knightlinc/Write')
local mqutil = require('utils/mqhelpers')
local spell = require('core/casting/spell')

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

  -- validate this wont kill us. https://discord.com/channels/511690098136580097/866047684242309140/1271477971575767111
  if self.MQSpell.HasSPA(0)() then
   for i = 1, self.MQSpell.NumEffects() + 1 do
       if self.MQSpell.Attrib(i)() == 0 then
           if mq.TLO.Me.CurrentHPs() + self.MQSpell.Base(i)() <= 0 then
             logger.Debug("\awUseItem(\ag%s\aw): \arTried to use item - but it would kill me!: %s! HPs: %d SpaHP: %d", self.Name, self.MQSpell.Name(),
             mq.TLO.Me.CurrentHPs(), self.MQSpell.Base(i)())
             return false
           end
       end
   end
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