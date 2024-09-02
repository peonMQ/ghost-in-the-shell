local logger = require('knightlinc/Write')

---@class MedleyStateEnum
---@field public Id integer
---@field public Name string
local MedleyStateEnum = {
  Id = 0,
  Name = "",
  __eq = function (self, medleyState)
    return self.Id == medleyState.Id
  end,
  __tostring = function (self)
    return self.Name
  end
}

---@param id integer
---@param name string
---@return MedleyStateEnum
function MedleyStateEnum:new(id, name)
  self.__index = self
  local o = setmetatable({}, self)
  o.Id = id or logger.Fatal("Id is required for <MedleyState>")
  o.Name = name or logger.Fatal("Name is required for <MedleyState>")
  return o
end

---@class MedleyStates
local MedleyStates = {
  UNINITALIZED = MedleyStateEnum:new(0, "UNINITALIZED"),
  IDLE = MedleyStateEnum:new(1, "IDLE"),
  CASTING = MedleyStateEnum:new(2, "CASTING"),
  PAUSED = MedleyStateEnum:new(3, "PAUSED"),
}

return MedleyStates