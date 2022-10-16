--- @type Mq
local mq = require('mq')
---@type Cast
local cast = require('lib/spells/types/cast')
local castReturnTypes = require('lib/spells/types/castreturn')
local logger = require('utils/logging')
local state = require('lib/spells/state')

---@class AltAbility : Cast
---@field public Id integer
---@field public Name string
---@field public MaxResists integer
local AltAbility = cast:base()

---@param name string
---@return AltAbility
function AltAbility:new (name)
  self.__index = self
  if not mq.TLO.Me.AltAbilityReady(name)() then
    logger.Fatal("<%s> is not a valid alt ability.", name)
  end

  local id = mq.TLO.Me.AltAbility(name).ID()
  local o = setmetatable(cast:new(id, name), self)
  o.MaxResists = 0
  return o --[[@as AltAbility]]
end

---@param cancelCallback fun(spelLId:integer)
---@return CastReturn
function AltAbility:Cast(cancelCallback)
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

  repeat
    if (not mq.TLO.Me.AltAbilityReady(self.Name)()) then
      return castReturnTypes.NotReady
    end

    mq.cmdf("/alt activate %s", mq.TLO.Me.AltAbility(self.Name).ID())
    mq.delay(5, function() return mq.TLO.Me.Casting.ID() or false end)
    self:DoCastEvents()
    self:WhileCasting(cancelCallback)
  until (not state.castReturn.AbilityRetry and
         (state.castReturn == castReturnTypes.Resisted and state.resistCounter > self.MaxResists)) or
        state.giveUpTimer:IsComplete()

  self:DoCastEvents()
  logger.Debug("Ability completed for <%s> with result <%s>", self.Name, state.castReturn)
  return state.castReturn
end

return AltAbility