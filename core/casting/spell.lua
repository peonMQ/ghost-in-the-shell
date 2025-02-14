local mq = require('mq')
local logger = require('knightlinc/Write')
local cast = require('core/casting/cast')
local timer = require('core/timer')
local castReturnTypes = require('core/casting/castreturn')
local debugutils = require('utils/debug')
local state = require('application/casting/casting_state')

---@class Spell : Cast
---@field public DefaultGem integer
---@field public MinManaPercent integer
---@field public GiveUpTimer integer
---@field public MaxResists integer
---@field public MQSpell spell
local Spell = cast:base()

---@return Spell
function Spell:base()
  self.__index = self
  local o = setmetatable(cast:base(), self)
  o.DefaultGem = 0
  return o --[[@as Spell]]
end

---@param name string
---@param defaultGem? integer
---@param minManaPercent? integer
---@param giveUpTimer? integer
---@param maxResists? integer
---@return Spell
function Spell:new (name, defaultGem, minManaPercent, giveUpTimer, maxResists)
  self.__index = self
  if not mq.TLO.Spell(name)() then
    logger.Error("<%s> is not a valid spell.", name)
  end

  local spellBookPosition = mq.TLO.Me.Book(name)()
  if not spellBookPosition then
    logger.Error("<%s> is not availbable in spellbook.", name)
  end

  local id = mq.TLO.Spell(name).ID()
  local o = setmetatable(cast:new(id, name), self)
  o.DefaultGem = defaultGem or 0
  o.MinManaPercent = minManaPercent or 100
  o.GiveUpTimer = giveUpTimer or 0
  o.MaxResists = maxResists or 0
  o.MQSpell = mq.TLO.Spell(name) --[[@as spell]]
  return o --[[@as Spell]]
end



---@param cancelCallback? fun(spelLId:integer)
---@param readyTimer? integer|nil
---@return boolean
function Spell:MemSpell(cancelCallback, readyTimer)
  local me = mq.TLO.Me
  if me.Gem(self.Name)() then
    return true
  end

  if self.DefaultGem < 1 then
    return false
  end

  mq.cmdf('/memspell %d "%s"', self.DefaultGem, self.Name)
  mq.delay(10)

  local memTimer = timer:new(6)
  while not me.Gem(self.Name)() and memTimer:IsRunning() do
    if cancelCallback and cancelCallback(self.Id) then
      self:Interrupt()
      return false
    end
  end

  local spellReadyTimer = timer:new(readyTimer or 10)
  while not me.SpellReady(self.Name)() and spellReadyTimer:IsRunning() do
    if cancelCallback and cancelCallback(self.Id) then
      self:Interrupt()
      return false
    end
  end

  return true
end

---@return boolean
function Spell:CanCast()
  local superCanCast = cast.CanCast(self)
  if not superCanCast then
    return false
  end

  local me = mq.TLO.Me
  if me.PctMana() < self.MinManaPercent or mq.TLO.Spell(self.Name).Mana() > me.CurrentMana() then
    logger.Debug("Unable to cast <%s>, not enough mana.", self.Name)
    return false
  end

  return true
end

---@param cancelCallback? fun(spellId:integer)
---@return CastReturn
function Spell:Cast(cancelCallback)
  state.Reset(self.GiveUpTimer)

  local spell = self.MQSpell
  if(mq.TLO.Me.CurrentMana() < spell.Mana()) then
    logger.Debug("Unable to cast <%s>, not enough mana.", self.Name)
    return castReturnTypes.OutOfMana
  end

  if not self:MemSpell(cancelCallback) then
    logger.Debug("Unable to cast <%s>, not in any spell gem and default spell gem is not defined.", self.Name)
    return castReturnTypes.NotMemmed
  end

  if mq.TLO.Me.SpellInCooldown() then
    logger.Warn("Spell in cooldown %s", mq.TLO.Me.SpellInCooldown())
    mq.delay(2500, function() return not mq.TLO.Me.SpellInCooldown() end)
  end

  if not mq.TLO.Me.SpellReady(self.Name)() then
    logger.Debug("Unable to cast <%s>, spell not ready.", self.Name)
    return castReturnTypes.NotReady
  end

  if (mq.TLO.Window("SpellBookWnd").Open()) then
    mq.cmd("/keypress spellbook")
  end

  if (mq.TLO.Me.Ducking()) then
    mq.cmd("/keypress duck")
  end

  if (mq.TLO.Me.Sitting()) then
    mq.cmd("/stand")
  end

  if mq.TLO.Me.Animation()  == 16 then
    mq.cmd("/stand")
  end

  state.recastTime = spell.RecastTime()
  state.recoveryTime = spell.RecoveryTime()

  local totalCastTime = mq.gettime()
  repeat
    mq.delay(state.retryTimer:TimeRemaining(), function() return mq.TLO.Me.SpellReady(self.Name)() end)
    mq.cmdf('/cast "%s"', self.Name)
    mq.delay(200)
    self:DoCastEvents()
    self:WhileCasting(cancelCallback)

    if (state.castReturn ~= castReturnTypes.Success
        and state.castReturn == castReturnTypes.Recover
        and state.giveUpTimer:IsComplete()) then
          logger.Debug("Spell <%s> is not ready.", self.Name)
          return castReturnTypes.NotReady
    end

    if (mq.TLO.Me.Stunned()) then
      mq.delay('10s', function() return mq.TLO.Me.Stunned() == false end)
    end

    if not state.castReturn then
      logger.Error("State current cast return is <nil>")
    end
  until (not state.castReturn.SpellRetry and
         (state.castReturn == castReturnTypes.Resisted and state.resistCounter > self.MaxResists)) or
        state.castReturn == castReturnTypes.Success or
        state.retryTimer:TimeRemaining() > state.giveUpTimer:TimeRemaining() or
        state.giveUpTimer:IsComplete()

  -- self:DoCastEvents()
  logger.Debug("Cast completed for <%s> in <%s> with result <%s>", self.Name, (mq.gettime() - totalCastTime)/1000, state.castReturn, state.castReturn)
  return state.castReturn
end

return Spell