local bardSpells = require 'data/spells_bard'
local beastlordSpells = require 'data/spells_beastlord'
local berserkerSpells = require 'data/spells_berserker'
local clericSpells = require 'data/spells_cleric'
local druidSpells = require 'data/spells_druid'
local enchanterSpells = require 'data/spells_enchanter'
local magicianSpells = require 'data/spells_magician'
local monkSpells = require 'data/spells_monk'
local necromancerSpells = require 'data/spells_necromancer'
local paladinSpells = require 'data/spells_paladin'
local rangerSpells = require 'data/spells_ranger'
local rogueSpells = require 'data/spells_rogue'
local shadowknightSpells = require 'data/spells_shadowknight'
local shamanSpells = require 'data/spells_shaman'
local warriorSpells = require 'data/spells_warrior'
local wizardSpells = require 'data/spells_wizard'

local function extractGroups(classGroups)
  local groups = {}
  for key, _ in pairs(classGroups) do
    table.insert(groups, key)
  end

  return groups
end

local SpellGroups = {
  BRD = bardSpells,
  BST = beastlordSpells,
  BER = berserkerSpells,
  CLR = clericSpells,
  DRU = druidSpells,
  ENC = enchanterSpells,
  MAG = magicianSpells,
  MNK = monkSpells,
  NEC = necromancerSpells,
  PAL = paladinSpells,
  RNG = rangerSpells,
  ROG = rogueSpells,
  SHD = shadowknightSpells,
  SHM = shamanSpells,
  WAR = warriorSpells,
  WIZ = wizardSpells,
}

return SpellGroups