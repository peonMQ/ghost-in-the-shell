local mq = require 'mq'
local logger = require("knightlinc/Write")
local lua_utils = require 'utils/debug'
local luapaths = require 'utils/lua-paths'
local spell_finder = require 'lib/spells/spell_finder'
local conversionSpell = require 'lib/caster/conversionspell'
local conversionItem = require 'lib/caster/conversionitem'
local curespell = require 'modules/curer/types/curespell'
local buffspell = require 'modules/buffer/types/buffspell'
local buffitem = require 'modules/buffer/types/buffitem'
local debuffSpell = require 'modules/debuffer/types/debuffspell'
local nukepell = require 'modules/nuker/types/nukespell'
local healSpell = require 'modules/healer/types/healspell'
local hotSpell = require 'modules/healer/types/hotspell'
local song = require 'lib/spells/types/song'


-- logger.callstringlevel = logger.loglevels.trace.level

local loader = require 'settings/loader'
local class_buffs = require 'data/class_buffs'
local spells_pet = require 'data/spells_pet'

local runningDir = luapaths.RunningDir:new()
local currentScript = runningDir:Parent():GetRelativeToMQLuaPath("")

local server_shortname = mq.TLO.MacroQuest.Server()
local settings_path = string.format("%s/%s/%s", mq.configDir, currentScript, server_shortname)
local server_settings_filename = string.format("%s/server_settings.lua",settings_path)
local class_settings_filename = string.format("%s/%s_settings.lua", settings_path, mq.TLO.Me.Class.Name():lower())
local bot_settings_filename = string.format("%s/bots/%s_settings.lua", settings_path, mq.TLO.Me.Name():lower())

---@alias ClassShortNames 'BRD'|'BST'|'BER'|'CLR'|'DRU'|'ENC'|'MAG'|'MNK'|'NEC'|'PAL'|'RNG'|'ROG'|'SHD'|'SHM'|'WAR'|'WIZ'
---@alias LogLevel 'trace'|'debug'|'info'|'warn'|'error'|'fail'
---@alias AssitTypes 'melee'|'ranged'|nil

---@class PeerSettings
---@field public loglevel LogLevel Enable debug logs
---@field public looter boolean Is looter
---@field public assist PeerSettingsAssist
---@field public buffs PeerSettingsBuff
---@field public pet PeerSettingsPet | nil
---@field public gems table<string, integer> key is string, val is integer
---@field public cures table<string, CureSpell> spell group of buff groups to request
---@field public heal PeerSettingsHealing spell group of buff groups to request
---@field public mana PeerSettingsMana Override default mana/endurance regeneration
---@field public medleys table<string, Song[]> | nil Medley settings for bards
---@field public medleyPadTimeMs number # Timer in MS added to each cast to determine when to do stopcast

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
---@field public buffs table<string, BuffSpell|BuffItem> spell group of pet buffs
---@field public taunt boolean pet should taunt

---@class PeerSettingsMana
---@field public meditate number
---@field public meditate_with_mob_in_camp boolean
---@field public conversions table<string, ConversionItem|ConversionSpell>

---@class PeerSettingsHealing
---@field public default table<string, HealSpell>|nil
---@field public mt_heal table<string, HealSpell>|nil
---@field public mt_emergency_heal table<string, HealSpell>|nil
---@field public hot table<string, HotSpell>|nil
---@field public ae_group table<string, HealSpell>|nil

---@class ApplicationSettings : PeerSettings
---@field public ReloadSettings fun(self: ApplicationSettings) Reload settings from files
---@field public GetDefaultGem fun(self: ApplicationSettings, spell_group_or_name: string): number Get default gem for given spell group or spell name

---@type PeerSettings
local default_settings = {
  loglevel = 'info',
  looter = false,
  gems = {
    default = 5
  },
  cures = {},
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
  heal = {
  },
  pet = {
    type = nil,
    engage_at = 0,
    buffs = {},
    taunt = false
  },
  medleyPadTimeMs = 0
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

  return self.gems.default or default_settings.gems.default
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
      local spell = spell_finder.FindSpell(name)
      if spell then
        availableSpells[name] = mapSpellFunc(name, spell.Name(), value)
      else
        spell = spell_finder.FindGroupSpell(name)
        if spell then
          availableSpells[name] = mapSpellFunc(name, spell.Name(), value)
        end
      end
    end
  end

  return availableSpells
end

---@generic T
---@param spelldata table<string, T>
---@param mapSpellFunc fun(groupname: string, name: string, data: T):T
---@param mapItemFunc? fun(name: string, data: T):T
---@return table<string, T>|nil
local function mapOptionalSpellOrItem(spelldata, mapSpellFunc, mapItemFunc)
  if not spelldata then
    return nil
  end

  return mapSpellOrItem(spelldata, mapSpellFunc, mapItemFunc)
end

---@generic T
---@param songlist string[]
---@param mapSongFunc fun(name: string, defaultgem: number): Song
---@return array<Song>
local function mapSong(songlist, mapSongFunc)
  local availableSpells = {}
  for index, name in ipairs(songlist) do
    local spell = spell_finder.FindSpell(name)
    if spell then
      table.insert(availableSpells, mapSongFunc(spell.Name(), index))
    else
      spell = spell_finder.FindGroupSpell(name)
      if spell then
        table.insert(availableSpells, mapSongFunc(spell.Name(), index))
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
  else
    self.pet.buffs = mapSpellOrItem(self.pet.buffs,
                                      function (groupname, name, data) return buffspell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.ClassRestrictions) end,
                                      function (name, data) return buffitem:new(name, data.ClassRestrictions) end)
  end

  -- if not self.buffs.request or not next(self.buffs.request) then
  --   self.buffs.request = class_buffs[mq.TLO.Me.Class.ShortName()] or {}
  -- end

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

  logger.Debug("Loading combat buff settings")
  self.buffs.request = mapSpellOrItem(self.buffs.request,
                                          function (groupname, name, data) return buffspell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.ClassRestrictions) end,
                                          function (name, data) return buffitem:new(name, data.ClassRestrictions) end
                                          )

  logger.Debug("Loading heal default settings")
  self.heal.default = mapOptionalSpellOrItem(self.heal.default,
                                          function (groupname, name, data) return healSpell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.HealPercent, data.HealDistance) end
                                          )

  logger.Debug("Loading heal mt_heal settings")
  self.heal.mt_heal = mapOptionalSpellOrItem(self.heal.mt_heal,
                                          function (groupname, name, data) return healSpell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.HealPercent, data.HealDistance) end
                                          )

  logger.Debug("Loading heal mt_emergency_heal settings")
  self.heal.mt_emergency_heal = mapOptionalSpellOrItem(self.heal.mt_emergency_heal,
                                          function (groupname, name, data) return healSpell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.HealPercent, data.HealDistance) end
                                          )

  logger.Debug("Loading heal hot settings")
  self.heal.hot = mapOptionalSpellOrItem(self.heal.hot,
                                          function (groupname, name, data) return hotSpell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.HealPercent, data.HealDistance) end
                                          )

  logger.Debug("Loading heal ae_group settings")
  self.heal.ae_group = mapOptionalSpellOrItem(self.heal.ae_group,
                                          function (groupname, name, data) return healSpell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.HealPercent, data.HealDistance) end
                                          )

  logger.Debug("Loading medley settings")
  if self.medleys then
    local availableMedleys = {}
    for key, medley in pairs(self.medleys) do
      local availableSongs = mapSong(medley, function (name, defaultgem) return song:new(name, defaultgem) end)
      if next(availableSongs) then
        availableMedleys[key] = availableSongs
      end
    end

    self.medleys = availableMedleys
  end
end

local function saveSettings()
end

settings:ReloadSettings()
logger.Debug("settings\n %s", lua_utils.ToString(settings))

return settings