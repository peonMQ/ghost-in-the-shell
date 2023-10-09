local configLoader = require 'utils/configloader'
---@type CureSpell
local curespell = require 'modules/curer/types/curespell'


---@class CureConfig
---@field public CurePoison CureSpell|nil
---@field public CureDisease CureSpell|nil
local defaultConfig = {
  CurePoison = {},
  CureDisease = {},
}

---@return CureSpell|nil
local function reMapCureSpell(spell)
  if not spell or not next(spell) then
    return nil
  end

  return curespell:new(spell.Name, spell.DefaultGem, spell.MinManaPercent, spell.GiveUpTimer)
end

---@return CureConfig
local function loadConfig()
  local config = configLoader("cures", defaultConfig)
  config.CurePoison = reMapCureSpell(config.CurePoison)
  config.CureDisease = reMapCureSpell(config.CureDisease)
  return config
end

local config = loadConfig()
return config
