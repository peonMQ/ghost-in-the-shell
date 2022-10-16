--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')

---@class MQEvent
---@field public Name string
---@field public Expression string
---@field public CallBack function
local MQEvent = {Name = '',  Expression = '', Callback = function() end}

---@param name string
---@param expression string
---@param callback function
---@return MQEvent
function MQEvent:new (name, expression, callback)
  self.__index = self
  local o = setmetatable({}, self)
  o.Name = name or logger.Fatal("Missing event name")
  o.Expression = expression  or logger.Fatal("Missing event expression")
  o.Callback = callback or function() end
  return o
end

function MQEvent:Register()
  mq.event(self.Name, self.Expression, self.Callback)
end

function MQEvent:DoEvent()
  mq.doevents(self.Name)
end

function MQEvent:Flush()
  mq.flushevents(self.Name)
end

return MQEvent