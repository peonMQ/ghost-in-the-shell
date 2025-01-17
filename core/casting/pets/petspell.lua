--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')
---@type Spell
local spell = require('core/casting/spell')

---@class PetSpell : Spell
local PetSpell = spell:base()

---@param name string
---@param defaultGem integer?
---@param minManaPercent integer?
---@param giveUpTimer integer?
---@return PetSpell
function PetSpell:new(name, defaultGem, minManaPercent, giveUpTimer)
  self.__index = self
  local o = setmetatable(spell:new(name, defaultGem, minManaPercent, giveUpTimer), self)
  return o --[[@as PetSpell]]
end

---@return boolean
function PetSpell:CanCast()
  local superCanCast = spell.CanCast(self)
  if not superCanCast then
    return false
  end

  local mqSpell = mq.TLO.Spell(self.Name)
  for i=1,4 do
    local reagentId = mqSpell.ReagentID(i)()
    local reagentCount = mqSpell.ReagentCount(i)()
    if reagentId > 0 and mq.TLO.FindItemCount(reagentId)() < reagentCount then
      logger.Warn("Insuffiecient reagents with id <%d>, need at least <%d>", reagentId, reagentCount)
      return false
    end
  end

  return true
end

return PetSpell