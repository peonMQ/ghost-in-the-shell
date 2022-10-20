local logger = require('utils/logging')
local config = require('utils/configloader')
local debugUtils = require('utils/debug')
--- @type LootItem
local item = require('modules/looter/types/lootitem')

local function getFilePath()
  local fileName = "Loot Settings"
  return string.format("data/%s", fileName)
end

local function loadStore()
  local filePath = getFilePath()
  local loadedConfig = config("", nil, filePath)
  local data = {}
  for key, value in pairs(loadedConfig) do
    table.insert(data, item:new(value.Id, value.Name, value.DoSell, value.DoDestroy))
  end

  return data
end

---@class Repository
local Repository = {
  items = loadStore()
}

---@param item LootItem
function Repository:add (item)
  table.insert(self.items, item)
end

---@param itemId integer
---@return boolean, LootItem?
function Repository:tryGet (itemId)
  for i, v in ipairs (self.items) do
    if (v.Id == itemId) then
      return true, v
    end
  end

  return false, nil
end

---@param upsertItem LootItem
function Repository:upsert (upsertItem)
  for k, v in ipairs (self.items) do
    if (v.Id == upsertItem.Id) then
      self.items[k] = upsertItem
      return
    end
  end

  self:add(upsertItem)
    local filePath = getFilePath()
    config.SaveConfig("", Repository.items, filePath)
end

return Repository