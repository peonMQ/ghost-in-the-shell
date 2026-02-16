local mq = require('mq')
local logger = require('knightlinc/Write')
local bci = require('broadcast/broadcastinterface')('REMOTE')
local luaLoader = require 'utils/loaders/lua-table'
local debugUtils = require('utils/debug')
local item = require('core/lootitem')
local binder = require('application/binder')

local configDir = mq.configDir
local serverName = mq.TLO.MacroQuest.Server()

local function getFilePath()
  local fileName = "loot_settings.lua"
  return string.format("%s/gits/%s/data/%s", configDir, serverName, fileName)
end

---@param items LootItem[]
local function save(items)
  table.sort(items, function(a,b)
      if a.Name == b.Name then
        return a.Id < b.Id
      end

      return a.Name < b.Name
    end)
  local filePath = getFilePath()
  luaLoader.SaveTable(filePath, items)
  bci.ExecuteAllCommand("/loot_reload")
end

---@class Repository
---@field items LootItem[]
local Repository = {
  items = {}
}

function Repository:loadStore()
  local filePath = getFilePath()
  local loadedConfig = luaLoader.LoadTable(filePath)
  local data = {}
  for key, value in pairs(loadedConfig) do
    table.insert(data, item:new(value.Id, value.Name, value.DoSell, value.DoDestroy, value.NumberOfStacks))
  end

  table.sort(data, function(a,b) return a.Name < b.Name end)
  self.items = data
end

---@param item LootItem
function Repository:add(item)
  table.insert(self.items, item)
  save(Repository.items)
end

---@param index number
function Repository:remove(index)
  logger.Info("Removing index %s from loot repository with item %s", index, self.items[index].Name)
  table.remove(self.items, index)
  save(Repository.items)
end

---@param itemId integer
---@return LootItem?
function Repository:tryGet(itemId)
  for i, v in ipairs (self.items) do
    if (v.Id == itemId) then
      return v
    end
  end

  return nil
end

---@param upsertItem LootItem
function Repository:upsert(upsertItem)
  for k, v in ipairs (self.items) do
    if (v.Id == upsertItem.Id) then
      self.items[k] = upsertItem
      save(Repository.items)
      return
    end
  end

  self:add(upsertItem)
  save(Repository.items)
end

binder.Bind("/loot_reload", function() Repository:loadStore() end, "Tells bot to reload the loot settings file.")

Repository:loadStore()
return Repository