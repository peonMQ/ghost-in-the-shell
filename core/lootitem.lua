---@class LootItem
---@field public Id integer
---@field public Name string
---@field public DoSell boolean
---@field public DoDestroy boolean
---@field public NumberOfStacks number|nil
local LootItem = {Id = 0, Name = '', DoSell = false, DoDestroy = false, NumberOfStacks = nil}

---@param id integer
---@param name string
---@param doSell? boolean
---@param doDestroy? boolean
---@param numberOfStacks? number
---@return LootItem
function LootItem:new (id, name, doSell, doDestroy, numberOfStacks)
  self.__index = self
  local o = setmetatable({}, self)
  o.Id = id or 0
  o.Name = name or ''
  o.DoSell = doSell or false
  o.DoDestroy = doDestroy or false
  o.NumberOfStacks = numberOfStacks
  return o
end

return LootItem