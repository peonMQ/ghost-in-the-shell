--- @type Mq
local mq = require 'mq'
---@type Spell
local spell = require 'lib/spells/types/spell'
local logger = require("knightlinc/Write")
local luaUtils = require 'utils/lua-table'

---@class CureSpell : Spell
---@field public Id integer
---@field public Name string
---@field public DefaultGem integer
---@field public MinManaPercent integer
---@field public GiveUpTimer integer
---@field public CounterType string
local CureSpell = spell:base()

---@param name string
---@param defaultGem integer
---@param minManaPercent integer
---@param giveUpTimer integer
---@return CureSpell
function CureSpell:new (name, defaultGem, minManaPercent, giveUpTimer)
  self.__index = self
  local o = setmetatable(spell:new(name, defaultGem, minManaPercent, giveUpTimer), self)
  o.CounterType = mq.TLO.Spell(o.Id).CounterType()
  return o --[[@as CureSpell]]
end

---@param spawn spawn
---@return boolean
function CureSpell:CanCastOnSpawn(spawn)
  local superCanCast = spell.CanCast(self)
  if not superCanCast then
    return false
  end

  local spell = mq.TLO.Spell(self.Name)
  if spawn.Distance() and spawn.Distance() > spell.Range() then
    return false
  end

  return true
end

---@param netbot netbot
---@return boolean
function CureSpell:CanCastOnNetBot(netbot)
  local spawn = mq.TLO.Spawn(netbot.ID())
  if not spawn.ID() then
    return false
  end

  if (tonumber(netbot.Poisoned()) or 0) > 0 and self.CounterType == "Poison" then
    return self:CanCastOnSpawn(spawn --[[@as spawn]])
  elseif (tonumber(netbot.Diseased()) or 0) > 0 and self.CounterType == "Disease" then
    return self:CanCastOnSpawn(spawn --[[@as spawn]])
  end

  return false
end

return CureSpell