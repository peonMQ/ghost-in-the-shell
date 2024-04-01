--- @type Mq
local mq = require('mq')
local logger = require("knightlinc/Write")

-- https://www.eqprogression.com/magician-pet-stats/

---@alias MagePetTypes 'Air'|'Earth'|'Fire'|'Water'

--- @param type MagePetTypes
--- @return string[]
local function magicianPetSpells(type)
  if not type then
    type = "Water"
  end

  return {
    string.format("Elementalkin: %s", type),        -- L02
    string.format("Elementaling: %s", type),        -- L06
    string.format("Elemental: %s", type),           -- L10
    string.format("Minor Summoning: %s", type),     -- L14
    string.format("Lesser Summoning: %s", type),    -- L18
    string.format("Summoning: %s", type),           -- L22
    string.format("Greater Summoning: %s", type),   -- L26
    string.format("Minor Conjuration: %s", type),   -- L31
    string.format("Lesser Conjuration: %s", type),  -- L36
    string.format("Conjuration: %s", type),         -- L41
    string.format("Greater Conjuration: %s", type), -- L49
    string.format("Vocarate: %s", type),            -- L54
    string.format("Greater Vocaration: %s", type),  -- L60
    "Servant of Marr",                              -- L62 (pet ROG/60) - no reagent
    string.format("Child of %s", type),             -- L67 (pet ROG/65) - Malachite
  }
end

local function necromancerPetSpells(type)
  return {
    "Cavorting Bones",       -- L01
    "Leering Corpse",        -- L04
    "Bone Walk",             -- L08
    "Convoke Shadow",        -- L12
    "Restless Bones",        -- L16
    "Animate Dead",          -- L20
    "Haunting Corpse",       -- L24
    "Summon Dead",           -- L29
    "Invoke Shadow",         -- L33
    "Malignant Dead",        -- L39 (pet WAR/33)
    "Servant of Bones",      -- L56 (pet MNK/44)
    "Emissary of Thule",     -- L59 (pet WAR/47)
    "Legacy of Zek",         -- L61 (pet WAR/60)
    "Saryrn's Companion",    -- L63 (pet ROG/60)
    "Child of Bertoxxulous", -- L65 (pet WAR/60)
    "Lost Soul",             -- L67 (pet WAR/65)
    "Dark Assassin",         -- L70 (pet ROG/65)
    "Riza`farr's Shadow",    -- L72
    "Putrescent Servant",    -- L75
    "Relamar's Shade",       -- L77
    "Noxious Servant",       -- L80
  }
end

local function shamanSpells(type)
  return {
    "Companion Spirit",     -- L32
    "Vigilant Spirit",      -- L37
    "Guardian Spirit",      -- L41
    "Frenzied Spirit",      -- L45
    "Spirit of the Howler", -- L55
    "True Spirit",          -- L61 (pet WAR/58)
    "Farrel's Companion",   -- L67 (pet WAR/63)
  }
end

local minorFocusItems = {
  Fire = "Torch of Alna",
  Earth = "Shovel of Ponz",
  Air = "Broom of Trilon",
  Water = "Stein of Ulissa"
}

--- /lua parse mq.TLO.FindItem("=Staff of Elemental Mastery: Water").Focus()

--- @param type MagePetTypes
--- @param spell spell
--- @return string?
local function getMagicianPetFocusItem(type, spell)
  if not type then
    type = "Water"
  end

  local petSummonFocusItem = string.format("Staff of Elemental Mastery: %s", type)
  if (spell.Level() >= 46 or spell.Level() <= 60) and mq.TLO.FindItem("="..petSummonFocusItem)() then
    return petSummonFocusItem
  end

  petSummonFocusItem = minorFocusItems[type]
  if (spell.Level() >= 4 or spell.Level() <= 49) and petSummonFocusItem and  mq.TLO.FindItem("="..petSummonFocusItem)() then
    return petSummonFocusItem
  end

  return nil
end

--- @param type string
--- @param spell spell
--- @return string?
local function getNecromancerPetFocusItem(type, spell)
  if spell.Level() < 45 or spell.Level() > 60 then
    return nil
  end

  local petSummonFocusItem = "Encyclopedia Necrotheurgia"
  if mq.TLO.FindItem("="..petSummonFocusItem)() then
    return petSummonFocusItem
  end

  return nil
end

---@class PetTypeSpells
---@field FocusItem? fun(string, spell):string|nil
---@field Spells fun(string?):string[]

---@type { [string]: PetTypeSpells }
local petSpells = {
  MAG = {
    FocusItem=getMagicianPetFocusItem,
    Spells = magicianPetSpells
  },
  NEC = {
    FocusItem=getNecromancerPetFocusItem,
    Spells = necromancerPetSpells
  },
  SHM = {
    FocusItem=function(string, spell) return nil end,
    Spells = shamanSpells
  }
}

--- @param type string?
--- @return spell?, string?
local function getPetSummonSpell(type)
  local class = mq.TLO.Me.Class.ShortName()
  local petTypeSpell = petSpells[class]
  if not petTypeSpell then
    return nil, nil
  end

  local petspell = nil
  for _, spellName in ipairs(petTypeSpell.Spells(type)) do
      local spellSlot = mq.TLO.Me.Book(mq.TLO.Spell(spellName).RankName.Name())
      if spellSlot() then
        local spell = mq.TLO.Me.Book((spellSlot()))
        if spell() ~= nil and (not petspell or spell.Level() > petspell.Level()) then
          petspell = spell --[[@as spell]]
        end
      else
          logger.Debug("Pet spell not in book: %s", spellName)
      end
  end

  if not petspell then
    logger.Debug("No pet spell found.")
    return nil, nil
  end

  return petspell, petTypeSpell.FocusItem(type, petspell--[[@as spell]])
end

return getPetSummonSpell