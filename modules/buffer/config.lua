--- @type Mq
local mq = require 'mq'
local logger = require 'utils/logging'

local configLoader = require 'utils/configloader'
---@type BuffSpell
local buffSpell = require 'modules/buffer/types/buffspell'
---@type BuffItem
local buffItem = require 'modules/buffer/types/buffitem'

---@type BuffSpell[]
local buffArray = {}

---@class BuffConfig
---@field public DoBuffsWithNpcInCamp boolean
---@field public SelfBuffs BuffSpell[]
---@field public NetBotBuffs BuffSpell[]
---@field public PetBuffs BuffSpell[]
local defaultConfig = {
  DoBuffsWithNpcInCamp = false,
  SelfBuffs = buffArray,
  NetBotBuffs = buffArray,
  PetBuffs = buffArray
}

local function reMapBuffspell(buffSpells)
  local mappedBuffspells = {}
  for key, value in pairs(buffSpells) do
    if mq.TLO.FindItem("="..value.Name)() then
      local buffitem = buffItem:new(value.Name, value.ClassRestrictions)
      table.insert(mappedBuffspells, buffitem)
    elseif mq.TLO.Spell(value.Name)() then
      local spell = buffSpell:new(value.Name, value.DefaultGem, value.MinManaPercent, value.GiveUpTimer, value.ClassRestrictions)
      table.insert(mappedBuffspells, spell)
    else
      logger.Error("Unable to map <%s> to a valid buff.", value.Name)
    end
  end
  return mappedBuffspells
end

---@return BuffConfig
local function loadConfig()
  local config = configLoader("buffs", defaultConfig)
  config.SelfBuffs = reMapBuffspell(config.SelfBuffs)
  config.NetBotBuffs = reMapBuffspell(config.NetBotBuffs)
  config.PetBuffs = reMapBuffspell(config.PetBuffs)
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