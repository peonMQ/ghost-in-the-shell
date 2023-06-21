local configLoader = require 'utils/configloader'
---@type HealSpell
local healSpell = require 'modules/healer/types/healspell'


---@class HealConfig
---@field public MainTankHeal HealSpell|nil
---@field public MainTankEmergencyHeal HealSpell|nil
---@field public GroupHeal HealSpell|nil
---@field public NetbotsHeal HealSpell|nil
---@field public AEGroupHeal HealSpell|nil
local defaultConfig = {
  MainTankHeal = {},
  MainTankEmergencyHeal = {},
  GroupHeal = {},
  NetbotsHeal = {},
  AEGroupHeal = {}
}

---@return HealSpell|nil
local function reMapHealSpell(spell)
  if not spell or not next(spell) then
    return nil
  end

  return healSpell:new(spell.Name, spell.DefaultGem, spell.MinManaPercent, spell.GiveUpTimer, spell.HealPercent, spell.HealDistance)
end

---@return HealConfig
local function loadConfig()
  local config = configLoader("heals", defaultConfig)
  config.MainTankHeal = reMapHealSpell(config.MainTankHeal)
  config.MainTankEmergencyHeal = reMapHealSpell(config.MainTankEmergencyHeal)
  config.GroupHeal = reMapHealSpell(config.GroupHeal)
  config.NetbotsHeal = reMapHealSpell(config.NetbotsHeal)
  config.AEGroupHeal = reMapHealSpell(config.AEGroupHeal)
  return config
end

local config = loadConfig()
return config

-- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- https://gist.github.com/paulmoore/1429475
-- https://stackoverflow.com/questions/65961478/how-to-mimic-simple-inheritance-with-base-and-child-class-constructors-in-lua-t
-- https://www.tutorialspoint.com/lua/lua_object_oriented.htm

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff("id 647")

-- /lua parse mq.TLO.Me.FindBuff("id 647")

-- /lua parse mq.TLO.Spawn(mq.TLO.Me.ID()).FindBuff('spa charisma')