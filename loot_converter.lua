local mq = require 'mq'
local logger = require 'utils/logging'
local luaLoader = require 'utils/loaders/lua-table'
local jsonUtil = require 'utils/loaders/json'
local debugUtils = require 'utils/debug'
local item = require 'modules/looter/types/lootitem'

local repository = require 'modules/looter/repository'

local configDir = mq.configDir.."/"
local serverName = mq.TLO.MacroQuest.Server()

local function getFilePath()
  local fileName = "Loot Settings.json"
  return string.format("%s/%s/data/%s", configDir, serverName, fileName)
end

local function loadStore()
  local filePath = getFilePath()
  local loadedConfig = jsonUtil.LoadJSON(filePath)
  for _, value in pairs(loadedConfig) do
    repository:add(item:new(value.Id, value.Name, value.DoSell, value.DoDestroy, value.NumberOfStacks))
  end
end
loadStore()
local fileName = "loot_settings.lua"
local filePath = string.format("%s/gits/%s/data/%s", configDir, serverName, fileName)
luaLoader.SaveTable(filePath, repository.items)