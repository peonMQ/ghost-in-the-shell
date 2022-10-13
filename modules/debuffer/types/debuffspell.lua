--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
---@type Spell
local spell = require('lib/spells/types/spell')
local debuffState = require('modules/debuffer/types/debuffstate')

---@class DeBuffSpell : Spell
---@field public Id integer
---@field public Name string
---@field public DefaultGem integer
---@field public MinManaPercent integer
local DeBuffSpell = spell:base()

---@param name string
---@param defaultGem integer
---@param minManaPercent integer
---@param giveUpTimer integer
---@param resistRetries integer
---@return DeBuffSpell
function DeBuffSpell:new (name, defaultGem, minManaPercent, giveUpTimer, resistRetries)
  self.__index = self
  local o = setmetatable(spell:new(name, defaultGem, minManaPercent, giveUpTimer, resistRetries), self)
  return o --[[@as DeBuffSpell]]
end

---@param target target
---@return boolean
function DeBuffSpell:CanCastOnTarget(target)
  local superCanCast = spell.CanCast(self)
  if not superCanCast then
    return false
  end

  if target.Distance() > self.MQSpell.Range() then
    return false
  end

  if target.Type() == "Corpse" then
    return false
  end

  if not target.Aggressive() then
    return false
  end

  -- local hasDeBuff = target.FindBuff("id "..self.Id)
  -- local hasSPADeBuff = target.FindBuff("spa "..deBuffSpell.SPA())
  -- if (hasDeBuff() and hasDeBuff.Duration.TotalSeconds() > 6) or (hasSPADeBuff() and hasSPADeBuff.Duration.TotalSeconds() > hasSPADeBuff.CastTime()) then
  --   return false
  -- end

  if debuffState:HasDebuff(target.ID(), self.MQSpell) then
    return false
  end

  return true
end

return DeBuffSpell
-- https://stackoverflow.com/questions/64468184/lua-oop-with-metatables-problems-loading-function-from-file

-- https://developpaper.com/lua-multiple-inheritance-code-instance/

-- https://stackoverflow.com/questions/6927364/lua-class-inheritance-problem