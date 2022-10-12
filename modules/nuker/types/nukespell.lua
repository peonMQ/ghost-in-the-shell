--- @type Mq
local mq = require('mq')
---@type Spell
local spell = require('lib/spells/types/spell')

---@class NukeSpell : Spell
---@field public Id integer
---@field public Name string
---@field public DefaultGem integer
---@field public MinManaPercent integer
---@field public GiveUpTimer integer
---@field public ResistsType integer
---@field public DPS float
local NukeSpell = spell:base()

---@param name string
---@param defaultGem integer
---@param minManaPercent integer
---@return NukeSpell
function NukeSpell:new (name, defaultGem, minManaPercent, giveUpTimer)
  self.__index = self
  local o = setmetatable(spell:new(name, defaultGem, minManaPercent, giveUpTimer), self)
  o.ResistType = mq.TLO.Spell(o.Id).ResistType()
  return o --[[@as NukeSpell]]
end



---@param spawn spawn
---@return boolean
function NukeSpell:CanCastOnspawn(spawn)
  local spell = mq.TLO.Spell(self.Name)
  
  if spawn.Distance() > spell.Range() then
    return false
  end

  if spawn.Type() == "Corpse" then
    return false
  end

  return true
end

return NukeSpell