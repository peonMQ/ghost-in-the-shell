--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local plugin = require('utils/plugins')
local configLoader = require('utils/configloader')

local next = next 

---@class CommonConfig
local defaultConfig = {
  MainTanks = {},
  MainAssists = {},
  AssistPct = 90,
  DoMeleeAsNonMeleeClass = false
}

---@return CommonConfig
local function loadConfig()
  local config = configLoader("general", defaultConfig)
  return config
end

local config = loadConfig()

return config