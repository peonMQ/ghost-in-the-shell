local mq = require 'mq'
local logger = require("knightlinc/Write")
local lua_utils = require 'utils/debug'


logger.prefix = string.format("\at%s\ax", "[GITS]")
logger.postfix = function () return string.format(" %s", os.date("%X")) end

-- logger.callstringlevel = logger.loglevels.trace.level

local loader = require 'settings/loader'
local class_buffs = require 'data/class_buffs'
local spells_pet = require 'data/spells_pet'

local server_shortname = mq.TLO.MacroQuest.Server()
local server_settings_filename = string.format("%s/gits2/%s/server_settings.lua", mq.configDir, server_shortname)
local class_settings_filename = string.format("%s/gits2/%s/%s_settings.lua", mq.configDir, server_shortname, mq.TLO.Me.Class.Name():lower())
local bot_settings_filename = string.format("%s/gits2/%s/bots/%s_settings.lua", mq.configDir, server_shortname, mq.TLO.Me.Name():lower())

---@alias ClassShortNames 'CLR'| 'ENC'
---@alias LogLevel 'trace'|'debug'|'info'|'warn'|'error'|'fail'
---@alias AssitTypes 'melee'|'ranged'|nil

---@class PeerSettings
---@field public loglevel LogLevel Enable debug logs
---@field public assist PeerSettingsAssist
---@field public buffs PeerSettingsBuff
---@field public pet PeerSettingsPet | nil
---@field public gems table<string, integer> key is string, val is integer
---@field public cures table<CounterTypes, CureSpell> spell group of buff groups to request
---@field public songs table<string, string[]> a songset with songs
---@field public meditate integer Override default mana/endurance % of when to auto med

---@class PeerSettingsAssist
---@field public type AssitTypes type of assist
---@field public engage_at integer engage at this HP %
---@field public tanks string[] ordered list of tanks
---@field public main_assist string[] ordered list of main assists
---@field public nukes table<string, NukeSpell[]> spell group of nukes
---@field public dots DeBuffSpell[] spell group of dots
---@field public debuffs DeBuffSpell[] spell group of debuffs

---@class PeerSettingsBuff
---@field public self BuffSpell[] BuffSpell spell group of self buffs
---@field public combat BuffSpell[] BuffSpell spell group of combat buffs
---@field public request BuffSpell[] BuffSpell spell group of request buffs
---@field public requestInCombat boolean request buffs while in combat

---@class PeerSettingsPet
---@field public type MagePetTypes|nil
---@field public engage_at integer engage at this HP %
---@field public buffs string[] spell group of pet buffs
---@field public taunt boolean pet should taunt

---@class ApplicationSettings : PeerSettings
---@field public ReloadSettings fun(self: ApplicationSettings) Reload settings from files
---@field public GetDefaultGem fun(self: ApplicationSettings, spell_group_or_name: string): number Get default gem for given spell group or spell name

---@type PeerSettings
local default_settings = {
  loglevel = 'info',
  gems = {
    default = 5
  },
  cures = {},
  songs = {},
  meditate = 90,
  assist = {
    type = nil,
    engage_at = 90,
    tanks = {},
    main_assist = {},
    nukes = {},
    dots = {},
    debuffs = {}
  },
  buffs = {
    self = {},
    combat = {},
    request = {},
    requestInCombat = false,
  },
  pet = {
    type = nil,
    engage_at = 0,
    buffs = {},
    taunt = false
  }
}

local settings = loader.LoadSettings(default_settings --[[@as ApplicationSettings]], server_settings_filename, class_settings_filename, bot_settings_filename)

function settings:ReloadSettings()
  logger.loglevel = settings.loglevel

  local new_settings = loader.LoadSettings(default_settings, server_settings_filename, class_settings_filename, bot_settings_filename)
  for key, _ in pairs(default_settings) do
    if new_settings[key] then
      self[key] = new_settings[key]
    end
  end

  if not self.buffs.request or not next(self.buffs.request) then
    self.buffs.request = class_buffs[mq.TLO.Me.Class.ShortName()] or {}
  end

  if not spells_pet(settings.pet.type) then
    self.pet = nil
  end
  -- local mapped_cures = {}
  -- for _, value in pairs(self.cures) do
  --   local cure_spell = cureSpell:new()
  -- end
end

local function saveSettings()
end

---@param spell_group_or_name string
---@return integer
function settings:GetDefaultGem(spell_group_or_name)
  for key, value in pairs(self.gems) do
    if key == spell_group_or_name then
      return value
    end
  end

  return self.gems.default or 5
end

settings:ReloadSettings()
logger.Debug("settings\n %s", lua_utils.ToString(settings))

return settings