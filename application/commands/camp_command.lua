local mq = require('mq')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local camp = require('core/camp')
local binder = require('application/binder')

---comments
---@param location ImVec4|nil
local function execute(location)
  if location then
    logger.Debug("Toggle camp On %s %s %s", location.x, location.y, location.z)
    camp.SetCamp(location)
  else
    logger.Debug("Toggle camp OFF")
    camp.SetCamp()
  end
end

local function createCommand(xString, yString, zString)
  local x = tonumber(xString)
  local y = tonumber(yString)
  local z = tonumber(zString)
  if x and y and z then
    commandQueue.Enqueue(function() execute(ImVec4(x, y, z, 0)) end)
  else
    commandQueue.Enqueue(function() execute() end)
  end
end

binder.Bind("/togglecamp", createCommand, "Tells bot to set 'x' 'y' 'z' as his/her current camp, or nothing to reset", 'x y z')

return execute