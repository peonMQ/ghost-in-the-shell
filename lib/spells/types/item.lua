--- @type Mq
local mq = require('mq')
---@type Cast
local cast = require('lib/spells/types/cast')

local castReturnTypes = require('lib/spells/types/castreturn')
local logger = require('utils/logging')
local state = require('lib/spells/state')

---@class Item : Cast
---@field public Id integer
---@field public Name string
---@field public ItemName string
local Item = cast:base()

---@param itemName string
---@return Item
function Item:new (itemName)
  self.__index = self
  local item = mq.TLO.FindItem("="..itemName)
  if not item() then
    logger.Fatal("<"..itemName.."> is not in inventory.")
  end

  local itemspell = item.Clicky
  if not itemspell() then
    logger.Fatal("<"..itemName.."> has no click effect.")
  end

  local id = itemspell.SpellID()
  local name = itemspell.Spell.Name()
  local o = setmetatable(cast:new(id, name), self)
  o.ItemName = itemName
  return o --[[@as Item]]
end

---@return boolean
function Item:CanCast()
  local item = mq.TLO.FindItem("="..self.ItemName)
  local refreshTimer = item.TimerReady()
  local me = mq.TLO.Me
  if me.Casting() or refreshTimer > 0 then
    return false
  end

  return true
end

---@param cancelCallback fun(spelLId:integer)
---@return CastReturn
function Item:Cast(cancelCallback)
  self:FlushCastEvents()
  state.Reset()
  
  if (mq.TLO.Window("SpellBookWnd").Open()) then
    mq.cmd("/keypress spellbook")
  end

  if (mq.TLO.Me.Ducking()) then
    mq.cmd("/keypress duck")
  end
  
  if (mq.TLO.Me.Sitting()) then
    mq.cmd("/stand")
  end

  local item = mq.TLO.FindItem("="..self.ItemName)
  repeat
    if (not item.TimerReady()) then
      return castReturnTypes.NotReady
    end

    mq.cmdf('/useitem "%s"', self.ItemName)
    mq.delay(5, function() return mq.TLO.Me.Casting.ID() or false end)
    self:DoCastEvents()
    self:WhileCasting(cancelCallback)
  until (not state.castReturn.SpellRetry and
         (state.castReturn == castReturnTypes.Resisted and state.resistCounter > 0)) or
        state.giveUpTimer:IsComplete()

  self:DoCastEvents()
  logger.Debug("Item cast completed for <%s> with result <%s>", self.Name, state.castReturn)
  return state.castReturn
end

return Item