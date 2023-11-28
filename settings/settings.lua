local mq = require 'mq'
local logger = require("knightlinc/Write")
local lua_utils = require 'utils/debug'
local spell_finder = require 'lib/spells/spell_finder'
local conversionSpell = require 'lib/caster/conversionspell'
local conversionItem = require 'lib/caster/conversionitem'
local curespell = require 'modules/curer/types/curespell'
local buffspell = require 'modules/buffer/types/buffspell'
local buffitem = require 'modules/buffer/types/buffitem'
local debuffSpell = require 'modules/debuffer/types/debuffspell'
local nukepell = require 'modules/nuker/types/nukespell'


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
---@field public cures table<string, CureSpell> spell group of buff groups to request
---@field public songs table<string, string[]> a songset with songs
---@field public mana PeerSettingsMana Override default mana/endurance regeneration

---@class PeerSettingsAssist
---@field public type AssitTypes type of assist
---@field public engage_at integer engage at this HP %
---@field public tanks string[] ordered list of tanks
---@field public main_assist string[] ordered list of main assists
---@field public nukes table<string, table<string, NukeSpell>> spell group of nukes
---@field public dots table<string, DeBuffSpell> spell group of dots
---@field public debuffs table<string, DeBuffSpell> spell group of debuffs

---@class PeerSettingsBuff
---@field public self table<string, BuffSpell|BuffItem> BuffSpell spell group of self buffs
---@field public combat table<string, BuffSpell|BuffItem> BuffSpell spell group of combat buffs
---@field public request table<string, BuffSpell|BuffItem> BuffSpell spell group of request buffs
---@field public requestInCombat boolean request buffs while in combat

---@class PeerSettingsPet
---@field public type MagePetTypes|nil
---@field public engage_at integer engage at this HP %
---@field public buffs table<string, BuffSpell> spell group of pet buffs
---@field public taunt boolean pet should taunt

---@class PeerSettingsMana
---@field public meditate number
---@field public meditate_with_mob_in_camp boolean
---@field public conversions table<string, ConversionItem|ConversionSpell>

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
  mana = {
    meditate = 90,
    meditate_with_mob_in_camp = false,
    conversions = {}
  },
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

---@generic T
---@param spelldata table<string, T>
---@param mapSpellFunc fun(groupname: string, name: string, data: T):T
---@param mapItemFunc? fun(name: string, data: T):T
---@return table<string, T>
local function mapSpellOrItem(spelldata, mapSpellFunc, mapItemFunc)
  local availableSpells = {}
  for name, value in pairs(spelldata) do
    if mapItemFunc and mq.TLO.FindItem("="..name)() then
      availableSpells[name] = mapItemFunc(name, value)
    else
      local spell = spell_finder.FindGroupSpell(name)
      if spell then
        availableSpells[name] = mapSpellFunc(name, spell.Name(), value)
      else
        spell = spell_finder.FindSpell(name)
        if spell then
          availableSpells[name] = mapSpellFunc(name, spell.Name(), value)
        end
      end
    end
  end

  return availableSpells
end

function settings:ReloadSettings()
  logger.loglevel = settings.loglevel

  local new_settings = loader.LoadSettings(default_settings, server_settings_filename, class_settings_filename, bot_settings_filename)
  for key, _ in pairs(default_settings) do
    if new_settings[key] then
      self[key] = new_settings[key]
    end
  end

  logger.Debug("Checking pet settings")
  if not spells_pet(settings.pet.type) then
    self.pet = nil
  end

  if not self.buffs.request or not next(self.buffs.request) then
    self.buffs.request = class_buffs[mq.TLO.Me.Class.ShortName()] or {}
  end

  logger.Debug("Loading conversion settings")
  self.mana.conversions = mapSpellOrItem(self.mana.conversions,
                                          function (groupname, name, data) return conversionSpell:new(name, self:GetDefaultGem(groupname), data.StartManaPct, data.StopHPPct) end,
                                          function (name, data) return conversionItem:new(name, data.StartManaPct, data.StopHPPct) end
                                          )

  logger.Debug("Loading cure settings")
  self.cures = mapSpellOrItem(self.cures, function (groupname, name, data) return curespell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer) end)

  logger.Debug("Loading debuff settings")
  self.assist.debuffs = mapSpellOrItem(self.assist.debuffs, function (groupname, name, data) return debuffSpell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.MaxResists) end)

  logger.Debug("Loading nuke settings")
  local availableNukes = {}
  for key, spells in pairs(self.assist.nukes) do
    ---@type NukeSpell[]
    local availableSpells = mapSpellOrItem(spells, function (groupname, name, data) return nukepell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer) end)

    if next(availableSpells) then
      availableNukes[key] = availableSpells
    end
  end
  self.assist.nukes = availableNukes

  logger.Debug("Loading self buff settings")
  self.buffs.self = mapSpellOrItem(self.buffs.self,
                                          function (groupname, name, data) return buffspell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.ClassRestrictions) end,
                                          function (name, data) return buffitem:new(name, data.ClassRestrictions) end
                                          )

  logger.Debug("Loading combat buff settings")
  self.buffs.combat = mapSpellOrItem(self.buffs.combat,
                                          function (groupname, name, data) return buffspell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.ClassRestrictions) end,
                                          function (name, data) return buffitem:new(name, data.ClassRestrictions) end
                                          )
end

local function saveSettings()
end

settings:ReloadSettings()
logger.Debug("settings\n %s", lua_utils.ToString(settings))

return settings