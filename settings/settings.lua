local mq = require('mq')
local logger = require('knightlinc/Write')
local lua_utils = require('utils/debug')
local luapaths = require('utils/lua-paths')
local spell_finder = require('application/casting/spell_finder')
local conversionSpell = require('core/casting/conversionspell')
local conversionItem = require('core/casting/conversionitem')
local curespell = require('core/casting/cures/curespell')
local buffspell = require('core/casting/buffs/buffspell')
local buffitem = require('core/casting/buffs/buffitem')
local debuffSpell = require('core/casting/debuffs/debuffspell')
local nukespell = require('core/casting/nukes/nukespell')
local nukeitem = require('core/casting/nukes/nukeitem')
local healSpell = require('core/casting/heals/healspell')
local hotSpell = require('core/casting/heals/hotspell')
local song = require('core/casting/song')


-- logger.callstringlevel = logger.loglevels.trace.level

local loader = require('settings/loader')
local class_buffs = require('data/class_buffs')
local spells_pet = require('data/spells_pet')

local runningDir = luapaths.RunningDir:new()
local currentScript = runningDir:Parent():GetRelativeToMQLuaPath("")

local server_shortname = mq.TLO.MacroQuest.Server()
local settings_path = string.format("%s/%s/%s", mq.configDir, currentScript, server_shortname)
local server_settings_filename = string.format("%s/server_settings.lua",settings_path)
local class_settings_filename = string.format("%s/%s_settings.lua", settings_path, mq.TLO.Me.Class.Name():lower():gsub("%s+", ""))
local bot_settings_filename = string.format("%s/bots/%s_settings.lua", settings_path, mq.TLO.Me.Name():lower())

---@alias ClassShortNames 'BRD'|'BST'|'BER'|'CLR'|'DRU'|'ENC'|'MAG'|'MNK'|'NEC'|'PAL'|'RNG'|'ROG'|'SHD'|'SHM'|'WAR'|'WIZ'
---@alias LogLevel 'trace'|'debug'|'info'|'warn'|'error'|'fail'
---@alias AssitTypes 'melee'|'ranged'|nil

---@class PeerSettings
---@field public loglevel LogLevel Enable debug logs
---@field public looter boolean Is looter
---@field public isLockpicker boolean Is lockpicker
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
---@field public require_los boolean range of assist
---@field public range integer range of assist
---@field public engage_at integer engage at this HP %
---@field public tanks string[] ordered list of tanks
---@field public main_assist string[] ordered list of main assists
---@field public nukes table<string, table<string, NukeSpell|NukeItem>> spell group of nukes
---@field public pbaoe NukeSpell[] list of pbaoe nukes
---@field public dots table<string, DeBuffSpell> spell group of dots
---@field public debuffs table<string, DeBuffSpell> spell group of debuffs
---@field public aoe_stuns Spell[] list of available aoe stuns

---@class PeerSettingsBuff
---@field public self table<string, BuffSpell|BuffItem> BuffSpell spell group of self buffs
---@field public combat table<string, BuffSpell|BuffItem> BuffSpell spell group of combat buffs
---@field public request table<string, BuffSpell|BuffItem> BuffSpell spell group of request buffs
---@field public requestInCombat boolean request buffs while in combat

---@class PeerSettingsPet
---@field public type MagePetTypes|nil
---@field public engage_at integer engage at this HP %
---@field public combatbuffs table<string, BuffSpell|BuffItem> spell group of pet buffs
---@field public buffs table<string, BuffSpell|BuffItem> spell group of pet buffs
---@field public taunt boolean pet should taunt

---@class PeerSettingsMana
---@field public meditate number
---@field public meditate_with_mob_in_camp boolean
---@field public conversions table<string, ConversionSpell|ConversionItem>

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
  isLockpicker = false,
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
    require_los = true,
    range = 100,
    engage_at = 90,
    tanks = {},
    main_assist = {},
    nukes = {},
    pbaoe ={},
    dots = {},
    debuffs = {},
    aoe_stuns ={},
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
    combatbuffs = {},
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

---@generic T1, T2
---@param spelldata table<string, T1|T2>
---@param mapSpellFunc fun(groupname: string, name: string, data: T1):T1
---@param mapItemFunc? fun(name: string, data: T2):T2
---@return table<string, T1|T2>|nil
local function mapOptionalSpellOrItem(spelldata, mapSpellFunc, mapItemFunc)
  if not spelldata then
    return nil
  end

  return spell_finder.MapSpellsOrItems(spelldata, mapSpellFunc, mapItemFunc)
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
  local new_settings = loader.LoadSettings(default_settings, server_settings_filename, class_settings_filename, bot_settings_filename)
  for key, _ in pairs(default_settings) do
    if new_settings[key] then
      self[key] = new_settings[key]
    end
  end

  logger.loglevel = settings.loglevel

  logger.Debug("Checking pet settings")
  if not spells_pet(self.pet.type) then
    self.pet = nil
  else
    self.pet.buffs = spell_finder.MapSpellsOrItems(self.pet.buffs,
                                      function (groupname, name, data) return buffspell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.ClassRestrictions) end,
                                      function (name, data) return buffitem:new(name, data.ClassRestrictions) end)
    self.pet.combatbuffs = spell_finder.MapSpellsOrItems(self.pet.combatbuffs,
                                      function (groupname, name, data) return buffspell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.ClassRestrictions) end,
                                      function (name, data) return buffitem:new(name, data.ClassRestrictions) end)
  end

  -- if not self.buffs.request or not next(self.buffs.request) then
  --   self.buffs.request = class_buffs[mq.TLO.Me.Class.ShortName()] or {}
  -- end

  logger.Debug("Loading conversion settings")
  self.mana.conversions = spell_finder.MapSpellsOrItems(self.mana.conversions,
                                          function (groupname, name, data) return conversionSpell:new(name, self:GetDefaultGem(groupname), data.StartManaPct, data.StopHPPct) end,
                                          function (name, data) return conversionItem:new(name, data.StartManaPct, data.StopHPPct) end
                                          )

  logger.Debug("Loading cure settings")
  self.cures = spell_finder.MapSpellsOrItems(self.cures, function (groupname, name, data) return curespell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer) end)

  logger.Debug("Loading debuff settings")
  self.assist.debuffs = spell_finder.MapSpellsOrItems(self.assist.debuffs, function (groupname, name, data) return debuffSpell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.MaxResists) end)

  logger.Debug("Loading nuke settings")
  local availableNukes = {}
  for key, spells in pairs(self.assist.nukes) do
    ---@type NukeSpell[]
    local availableSpells = spell_finder.MapSpellsOrItems(spells
      , function (groupname, name, data) return nukespell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer) end
      , function (name, data) return nukeitem:new(name) end
    )

    if next(availableSpells) then
      availableNukes[key] = availableSpells
    end
  end
  self.assist.nukes = availableNukes

  logger.Debug("Loading pbaoe settings")
  local pbaoe_group_name = string.format("%s_pbae_nuke", mq.TLO.Me.Class.ShortName():lower())
  local availablePBAoEs = {}
  for _, spellName in ipairs(spell_finder.FindGroupSpells(pbaoe_group_name)) do
    local pbaoe_spell = nukespell:new(spellName, self:GetDefaultGem(pbaoe_group_name), 0, 0)
    table.insert(availablePBAoEs, pbaoe_spell)
  end
  self.assist.pbaoe = availablePBAoEs

  logger.Debug("Loading pbaoestun settings")
  local pbaoestun_group_name = string.format("%s_ae_stun", mq.TLO.Me.Class.ShortName():lower())
  local availablePBAoEStuns = {}
  for _, spellName in ipairs(spell_finder.FindGroupSpells(pbaoestun_group_name)) do
    local pbaoestun_spell = nukespell:new(spellName, self:GetDefaultGem(pbaoestun_group_name), 0, 0)
    table.insert(availablePBAoEStuns, pbaoestun_spell)
  end
  self.assist.aoe_stuns = availablePBAoEStuns

  logger.Debug("Loading self buff settings")
  self.buffs.self = spell_finder.MapSpellsOrItems(self.buffs.self,
                                          function (groupname, name, data) return buffspell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.ClassRestrictions) end,
                                          function (name, data) return buffitem:new(name, data.ClassRestrictions) end
                                          )

  logger.Debug("Loading combat buff settings")
  self.buffs.combat = spell_finder.MapSpellsOrItems(self.buffs.combat,
                                          function (groupname, name, data) return buffspell:new(name, self:GetDefaultGem(groupname), data.MinManaPercent, data.GiveUpTimer, data.ClassRestrictions) end,
                                          function (name, data) return buffitem:new(name, data.ClassRestrictions) end
                                          )

  logger.Debug("Loading combat buff settings")
  self.buffs.request = spell_finder.MapSpellsOrItems(self.buffs.request,
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
  if new_settings.medleys then
    local availableMedleys = {}
    for key, medley in pairs(new_settings.medleys) do
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