--- @type Mq
local mq = require('mq')
local configLoader = require('utils/configloader')
---@type DeBuffSpell
local debuffSpell = require('modules/debuffer/types/debuffspell')


---@type DeBuffSpell[]
local debuffArray = {}

---@class BuffConfig
---@field public DeBuffs DeBuffSpell[]
local defaultConfig = {
  DeBuffs = debuffArray,
}

---@param debuffSpells DeBuffSpell[]
---@return table
local function reMapDeBuffspell(debuffSpells)
  local mappedBuffspells = {}
  for key, value in pairs(debuffSpells) do
    local spell = debuffSpell:new(value.Name, value.DefaultGem, value.MinManaPercent, value.GiveUpTimer, value.MaxResists)
    table.insert(mappedBuffspells, spell)
  end
  return mappedBuffspells
end

---@return BuffConfig
local function loadConfig()
  local loadedConfig = configLoader("debuffs") --[[@as DeBuffSpell[] ]]
  defaultConfig.DeBuffs = reMapDeBuffspell(loadedConfig)
  return defaultConfig
end


local config = loadConfig()
return config

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff("id 647")

-- /lua parse mq.TLO.Me.FindBuff("id 647")

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff('spa charisma')