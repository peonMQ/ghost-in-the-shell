local logger = require 'utils/logging'
local configLoader = require 'utils/configloader'
---@type NukeSpell
local nukeSpell = require 'modules/nuker/types/nukespell'


---@type NukeSpell[]
local nukeArray = {}

---@class NukeConfig
---@field public Nukes NukeSpell[]
---@field public CurrentLineup NukeSpell[]
local deafultNukeConfig = {
  Nukes = {},
  CurrentLineup = {}
}

---@param nukeSpells NukeSpell[]
---@return NukeSpell[]
local function reMapBuffspell(nukeSpells)
  local mappedNukes = {}
  for key, value in pairs(nukeSpells) do
    local spell = nukeSpell:new(value.Name, value.DefaultGem, value.MinManaPercent, value.GiveUpTimer)
    table.insert(mappedNukes, spell)
  end
  return mappedNukes
end

local nukeConfig = configLoader("nuke", deafultNukeConfig)
nukeConfig.Nukes = reMapBuffspell(nukeConfig.Nukes)
nukeConfig.CurrentLineup = nukeConfig.Nukes

if not next(nukeConfig.CurrentLineup) then
  logger.Info("No nukes defined in config. Will skip nuking.")
end

return nukeConfig