local mq = require('mq')

---@class Timer
---@field public Duration integer
---@field public StartTime integer
local Timer = {Duration = 0, StartTime = mq.gettime()}

---@param duration? integer Duration in seconds
---@return Timer
function Timer:new (duration)
  self.__index = self
  local o = setmetatable({}, self)
  o.Duration = (duration or 0)*1000
  o.StartTime = mq.gettime()
  return o
end

---@return integer
function Timer:TimeRemaining()
  return self.Duration - (mq.gettime() - self.StartTime);
end

---@param newDuration number|nil
function Timer:Reset(newDuration)
  if(newDuration) then
    self.Duration = newDuration
  end
  self.StartTime = mq.gettime()
end

---@return boolean
function Timer:IsRunning()
  return self:TimeRemaining() >= 0;
end

---@return boolean
function Timer:IsComplete()
  return self:IsRunning() == false;
end

return Timer
