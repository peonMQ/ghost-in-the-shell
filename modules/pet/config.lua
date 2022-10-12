local configLoader = require('utils/configloader')
---@type Spell
local spell = require('lib/spells/types/spell')
---@type PetSpell
local petSpell = require('modules/pet/types/petspell')

---@class PetConfig
---@field public PetAssistPercent integer
---@field public PetTaunt boolean
---@field public CurrentPetTarget integer
---@field public PetSpell PetSpell
---@field public WeaponizeSpell Spell
local deafultPetConfig = {
  PetSpell = {},
  WeaponizeSpell = {},
  PetAssistPercent = 0,
  PetTaunt = false,
  CurrentPetTarget = 0
}


local petConfig = configLoader("pet", deafultPetConfig)

local defaultPetSpell = petConfig.PetSpell
if defaultPetSpell and defaultPetSpell.Name then
  petConfig.PetSpell = petSpell:new(defaultPetSpell.Name, defaultPetSpell.DefaultGem, defaultPetSpell.MinManaPercent, 5, defaultPetSpell.FocusItem)
end

local weaponizeSpell = petConfig.WeaponizeSpell
if weaponizeSpell and weaponizeSpell.Name then
  petConfig.WeaponizeSpell = spell:new(weaponizeSpell.Name, weaponizeSpell.DefaultGem, weaponizeSpell.MinManaPercent, 5)
end

return petConfig