local mq = require 'mq'
local events = require 'lib/spells/events'
local castReturnTypes = require 'lib/spells/types/castreturn'
local state = require 'lib/spells/state'
local logger = require("knightlinc/Write")

---@class Cast
---@field public Id integer
---@field public Name string
local Cast = {Id = 0, Name = ""}


---@return Cast
function Cast:base()
  self.__index = self
  local o = setmetatable({}, self)
  o.Id = 0
  o.Name = ""
  return o
end

---@param id integer
---@param name string
---@return Cast
function Cast:new (id, name)
  self.__index = self
  local o = setmetatable({}, self)
  o.Id = id or logger.Fatal("Id required.")
  o.Name = name or logger.Fatal("Name is required.")
  return o
end

function Cast:DoCastEvents()
  for _, value in ipairs(events) do
    value:DoEvent()
  end
  -- for i=1, #events do
  --   events[i]:DoEvent()
  -- end
end

function Cast:FlushCastEvents()
  for _, value in ipairs(events) do
    value:Flush()
  end
  -- for i=1, #events do
  --   events[i]:Flush()
  -- end
end

function Cast:Cast()
end

---@param cancelCallback? fun(spelLId:integer)
function Cast:WhileCasting(cancelCallback)
  local currentTarget = mq.TLO.Target
  local currentTargetId = currentTarget.ID()
  local currentTargetType = currentTarget.Type()
  while mq.TLO.Me.Casting.ID() do
    mq.delay(100)
    logger.Debug("Whilecasting <%s> [%s]", self.Name, state.castReturn.Name)
    if(cancelCallback) then
      cancelCallback(self.Id)
    elseif(currentTargetId and mq.TLO.Spawn(currentTargetId).Type() ~= currentTargetType) then
      logger.Info("Cancelling spell <%d>, current target <%s> is no longer available", self.Id, currentTargetId)
      state.interrupt()
    end

    self:DoCastEvents()
  end
end

---@return CastReturn
function Cast:Interrupt()
  state.interrupt()
  return state.castReturn
end


---@return boolean
function Cast:CanCast()
  local me = mq.TLO.Me
  if me.Stunned() then
    logger.Debug("Unable to cast <%s>, I am stunned.", self.Name)
    return false
  end

  if me.Casting() then
    logger.Debug("Unable to cast <%s>, I am already casting <%s>.", self.Name, me.Casting.Name())
    return false
  end

  return true
end

return Cast