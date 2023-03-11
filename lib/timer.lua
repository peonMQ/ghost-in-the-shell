---@class Timer
---@field public Duration integer
---@field public StartTime integer
local Timer = {Duration = 0, StartTime = mq.gettime()}

---@param duration? integer
---@return Timer
function Timer:new (duration)
  self.__index = self
  local o = setmetatable({}, self)
  o.Duration = duration*1000 or 0
  o.StartTime = mq.gettime()
  return o
end

---@return integer
function Timer:TimeRemaining()
  return self.Duration - (mq.gettime() - self.StartTime);
end

---@return integer
function Timer:DelayTime()
  return self:TimeRemaining() * 1000;
end

---@return boolean
function Timer:IsComplete()
  return self:TimeRemaining() >= self.Duration;
end

---@return boolean
function Timer:IsRunning()
  return self:IsComplete() == false;
end

return Timer
