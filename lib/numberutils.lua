local logger = require('utils/logging')

---@param value number
---@param min integer
---@return boolean
local function isLargerThan(value, min)
  if value ~= nil and min  ~= nil and value > min then
    return true
  end

  return false
end

---@param value number
---@param max integer
---@return boolean
local function isLessThan(value, max)
  if value ~= nil and max  ~= nil and value < max then
    return true
  end

  return false
end

local userdataUtils = {
  IsLargerThan = isLargerThan,
  IsLessThan = isLessThan,
}

return userdataUtils