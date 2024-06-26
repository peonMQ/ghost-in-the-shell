local mq = require 'mq'
local logger = require("knightlinc/Write")
local bci = require('broadcast/broadcastinterface')()
local luaLoader = require 'utils/loaders/lua-table'
local debugUtils = require 'utils/debug'
local item = require 'modules/looter/types/lootitem'

local configDir = mq.configDir
local serverName = mq.TLO.MacroQuest.Server()

local function getFilePath()
  local fileName = "loot_settings.lua"
  return string.format("%s/gits/%s/data/%s", configDir, serverName, fileName)
end

---@class Repository
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

  self.items = data
end

---@param item LootItem
function Repository:add(item)
  table.insert(self.items, item)
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
      return
    end
  end

  self:add(upsertItem)
  local filePath = getFilePath()
  luaLoader.SaveTable(filePath, Repository.items)
  bci.ExecuteAllCommand("/loot_reload")
end

mq.bind("/loot_reload", function() Repository:loadStore() end)

Repository:loadStore()
return Repository