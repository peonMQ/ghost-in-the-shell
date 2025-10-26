local mq = require('mq')
local logger = require('knightlinc/Write')
local cast = require ('core/casting/cast')
local castReturnTypes = require('core/casting/castreturn')
local state = require('application/casting/casting_state')
local timer = require('core/timer')

---@class Item : Cast
---@field public ItemName string
---@field public MQSpell spell
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
  o.MQSpell = itemspell.Spell --[[@as spell]];
  return o --[[@as Item]]
end

---@return boolean
function Item:CanCast()
  local superCanCast = cast.CanCast(self)
  if not superCanCast then
    return false
  end

  local item = mq.TLO.FindItem("="..self.ItemName)
  if not item then
    return false
  end

  local refreshTimer = item.TimerReady() or 1
  local me = mq.TLO.Me
  if me.Casting() or refreshTimer > 0 then
    return false
  end

  return true
end

---@param cancelCallback? fun(spellId:integer)
---@return CastReturn
function Item:Cast(cancelCallback)
  state.Reset()

  if mq.TLO.Window("SpellBookWnd").Open() then
    mq.cmd("/keypress spellbook")
  end

  if mq.TLO.Me.Ducking() then
    mq.cmd("/keypress duck")
  end

  if mq.TLO.Me.Sitting() then
    mq.cmd("/stand")
  end

  if mq.TLO.Me.Animation() == 16 then
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

---@param maxWaitTime number
---@return boolean
function Item:WaitForReady(maxWaitTime)
  local item = mq.TLO.FindItem("="..self.ItemName)
  if not item then
    return false
  end

  local waitReadyTimer = timer:new(maxWaitTime)
  while item.TimerReady() > 0 and waitReadyTimer:IsRunning() do
    mq.delay(500)
  end

  return item.TimerReady() == 0
end

return Item