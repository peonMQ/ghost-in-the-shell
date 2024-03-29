local mq = require 'mq'
local logger = require("knightlinc/Write")
local luaUtils = require 'utils/lua-table'
local spell_spa = require 'data/spell_spa'
local healSpell = require 'modules/healer/types/healspell'

---@class HotSpell : HealSpell
---@field public Id integer
---@field public Name string
---@field public DefaultGem integer
---@field public MinManaPercent integer
---@field public GiveUpTimer integer
---@field public HealPercent integer
---@field public HealDistance integer
local HotSpell = healSpell:base()

---@param name string
---@param defaultGem integer
---@param minManaPercent integer
---@param giveUpTimer integer
---@param healPercent integer
---@param healDistance integer
---@return HotSpell
function HotSpell:new (name, defaultGem, minManaPercent, giveUpTimer, healPercent, healDistance)
  self.__index = self
  local o = setmetatable(healSpell:new(name, defaultGem, minManaPercent, giveUpTimer, healPercent, healDistance), self)
  if not self.MQSpell.HasSPA(spell_spa.SPA_HEALDOT)() then
    logger.Fatal("<%s> is not a HOT spell.", name)
  end

  o.HealPercent = healPercent or 0
  o.HealDistance = healDistance or 200
  return o --[[@as HotSpell]]
end

---@param spawn spawn
---@return boolean
function HotSpell:CanCastOnSpawn(spawn)
  local superCanCast = healSpell.CanCast(self)
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
function HotSpell:CanCastOnTarget(target)
  if not target.PctHPs() or target.PctHPs() > self.HealPercent then
    return false
  end

  return self:CanCastOnSpawn(target)
end

---@param netbot netbot
---@return boolean
function HotSpell:CanCastOnNetBot(netbot)
  if (tonumber(netbot.PctHPs()) or 100) > self.HealPercent then
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
function HotSpell:CanCastOnGroupMember(groupMember)
  if not groupMember.Present() then
    return false
  end

  if groupMember.PctHPs() > self.HealPercent then
    return false
  end

  return self:CanCastOnSpawn(groupMember)
end

---@param netbot netbot
---@return boolean
function HotSpell:WillStack(netbot)
  local netbotBuffs = luaUtils.Split(netbot.Buff(), "%s")
  for _, buffId in ipairs(netbotBuffs) do
    if self.Id == tonumber(buffId) then
      return false
    end

    local buffSpell = mq.TLO.Spell(buffId)
    if buffSpell() and not mq.TLO.Spell(self.Id).WillStack(buffSpell.Name())() then
      return false
    end
  end

  if #netbotBuffs == 15 then
    return false
  end

  return true
end

return HotSpell