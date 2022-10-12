---@class SpawnSearchFilter
---@field public filter string
local SpawnSearchFilter = {filter = ''}

---@return SpawnSearchFilter
function SpawnSearchFilter:new ()
  self.__index = self
  local o = setmetatable({}, self)
  o.filter = ""
  return o
end

---@param id integer # Spawn ID
---@return SpawnSearchFilter
function SpawnSearchFilter:WithID(id)
  self.filter = string:format('%s id %d', self.filter, id)
  return self;
end

---@return SpawnSearchFilter
function SpawnSearchFilter:FilterByNPC()
  self.filter = string:format('%s npc', self.filter)
  return self;
end

---@return SpawnSearchFilter
function SpawnSearchFilter:FilterByPC()
  self.filter = string:format('%s pc', self.filter)
  return self;
end

---@return SpawnSearchFilter
function SpawnSearchFilter:FilterByLineOfSight()
  self.filter = string:format('%s los', self.filter)
  return self;
end

---@return SpawnSearchFilter
function SpawnSearchFilter:FilterByIsTargetable()
  self.filter = string:format('%s targetable', self.filter)
  return self;
end

---@param radius integer # Radius distance
---@return SpawnSearchFilter
function SpawnSearchFilter:WithRadius(radius)
  self.filter = string:format('%s radius %d', self.filter, radius)
  return self;
end

--[[
local filter = SpawnSearchFilter:new()
                                :WithID(10)
                                :WithRadius(10)
                                :FilterByIsTargetable()
                                .filter
]]

return SpawnSearchFilter
