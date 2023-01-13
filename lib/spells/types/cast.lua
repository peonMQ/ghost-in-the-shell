--- @type Mq
local mq = require('mq')
local events = require('lib/spells/events')
local castReturnTypes = require('lib/spells/types/castreturn')
local state = require('lib/spells/state')
local logger = require('utils/logging')

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
  -- for key, value in pairs(events) do
  --   value:DoEvent()
  -- end
  for i=1, #events do
    events[i]:DoEvent()
  end
end

function Cast:FlushCastEvents()
  -- for key, value in pairs(events) do
  --   value:Flush()
  -- end
  for i=1, #events do
    events[i]:Flush()
  end
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
    end

    if(currentTargetId and mq.TLO.Spawn(currentTargetId).Type() ~= currentTargetType) then
      logger.Info("Cancelling spell <%d>, current target <%s> is no longer available", self.Id, currentTarget())
      self:Interrupt()
    end

    self:DoCastEvents()
  end
end

---@return CastReturn
function Cast:Interrupt()
  logger.Debug("Interrupt casting <%s>.", mq.TLO.Me.Casting())
  mq.cmd("/stopcast")
  state.setCastReturn(castReturnTypes.Cancelled)
  mq.delay("1s", function () return not mq.TLO.Me.Casting.ID() end)
  return state.castReturn
end


---@return boolean
function Cast:CanCast()
  local me = mq.TLO.Me
  if me.Stunned() then
    logger.Debug("Unable to cast <%s>, I am stunned.", self.Name)
    return false
  end

  return true
end

return Cast