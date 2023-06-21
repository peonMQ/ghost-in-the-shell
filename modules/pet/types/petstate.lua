local logger = require 'utils/logging'

---@class PetState
---@field public Name string
local PetState = {Name = ""}

---@param name string
---@return PetState
function PetState:new (name)
  self.__index = self
  local o = setmetatable({}, self)
  o.Name = name or logger.Fatal("Name is required for <LootState>")
  return o
end

function PetState:__eq(petState)
  return self.Name == petState.Name
end 

function PetState:__tostring()
  return self.Name
end

---@class PetState
local PetStates = {
  Idle = PetState:new("IDLE"),
  SummonPet = PetState:new("SUMMON_PET"),
  WeaponizePet = PetState:new("WEAPONIZ_PET"),
}

return PetStates