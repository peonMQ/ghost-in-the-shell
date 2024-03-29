local mq = require 'mq'
local logger = require("knightlinc/Write")
local spell = require 'lib/spells/types/spell'

---@class HealSpell : Spell
---@field public Id integer
---@field public Name string
---@field public DefaultGem integer
---@field public MinManaPercent integer
---@field public GiveUpTimer integer
---@field public HealPercent integer
---@field public HealDistance integer
local HealSpell = spell:base()

---@param name string
---@param defaultGem integer
---@param minManaPercent integer
---@param giveUpTimer integer
---@param healPercent integer
---@param healDistance integer
---@return HealSpell
function HealSpell:new (name, defaultGem, minManaPercent, giveUpTimer, healPercent, healDistance)
  self.__index = self
  local o = setmetatable(spell:new(name, defaultGem, minManaPercent, giveUpTimer), self)
  o.HealPercent = healPercent or 0
  o.HealDistance = healDistance or 200
  return o --[[@as HealSpell]]
end

---@param spawn spawn
---@return boolean
function HealSpell:CanCastOnSpawn(spawn)
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

---@param target target
---@return boolean
function HealSpell:CanCastOnTarget(target)
  if not target.PctHPs() or target.PctHPs() > self.HealPercent then
    return false
  end

  return self:CanCastOnSpawn(target)
end

---@param netbot netbot
---@param heal_pct_adjustment? number
---@return boolean
function HealSpell:CanCastOnNetBot(netbot, heal_pct_adjustment)
  if (tonumber(netbot.PctHPs()) or 100) > self.HealPercent - (heal_pct_adjustment or 0) then
    return false
  end

  local spawn = mq.TLO.Spawn(netbot.ID())
  if not spawn.ID() then
    return false
  end

  return self:CanCastOnSpawn(spawn --[[@as spawn]])
end

---@param groupMember groupmember
---@return boolean
function HealSpell:CanCastOnGroupMember(groupMember)
  if not groupMember.Present() then
    return false
  end

  if groupMember.PctHPs() > self.HealPercent then
    return false
  end

  return self:CanCastOnSpawn(groupMember)
end

return HealSpell