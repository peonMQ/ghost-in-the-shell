--- @type Mq
local mq = require 'mq'
local logger = require("knightlinc/Write")
local luaUtils = require 'utils/lua-table'
---@type Spell
local spell = require 'lib/spells/types/spell'

local function currentZoneIsNoLevitate()
  local currentZone = mq.TLO.Zone.ShortName()
  return currentZone == "airplane"
end

local function currentZoneIsIndoors()
  local currentZone = mq.TLO.Zone.ShortName()
  return string.find("befallen blackburrow gukbottom guktop neriaka neriakb neriakc paw permafrost qcat runnyeye soldunga soldungb soltemple akanon kaladima kaladimb kedge kurn kaesora", currentZone) ~= nil
end

---@class BuffSpell : Spell
---@field public Id integer
---@field public Name string
---@field public DefaultGem integer
---@field public MinManaPercent integer
---@field public GiveUpTimer integer
---@field public ClassRestrictions string
local BuffSpell = spell:base()

---@param name string
---@param defaultGem integer
---@param minManaPercent integer
---@param giveUpTimer integer
---@param classRestrictions string
---@return BuffSpell
function BuffSpell:new (name, defaultGem, minManaPercent, giveUpTimer, classRestrictions)
  self.__index = self
  local o = setmetatable(spell:new(name, defaultGem, minManaPercent, giveUpTimer), self)
  o.ClassRestrictions = classRestrictions or ""
  return o --[[@as BuffSpell]]
end

---@return boolean
function BuffSpell:DoesLevitate()
  return string.find("Spirit of Eagle,Flight of Eagles,Levitate,Levitation,Dead Man Floating,Dead Men Floating", self.Name) ~= nil
end

---@return boolean
function BuffSpell:DoesIncreaseRunSpeed()
  return string.find("Spirit of Wolf,Spirit of Eagle,Flight of Eagles", self.Name) ~= nil
end

---@return boolean
function BuffSpell:CanCast()
  local superCanCast = spell.CanCast(self)
  if not superCanCast then
    return false
  end

  local buffSpell = mq.TLO.Spell(self.Name)
  if buffSpell.SpellType() ~= "Beneficial" then
    return false
  end

  if self:DoesIncreaseRunSpeed() and currentZoneIsIndoors() then
    return false
  end

  if self:DoesLevitate() and currentZoneIsNoLevitate() then
    return false
  end

  for i=1,4 do
    local reagentId = buffSpell.ReagentID(i)()
    local reagentCount = buffSpell.ReagentCount(i)()
    if reagentId > 0 and mq.TLO.FindItemCount(reagentId)() < reagentCount then
      logger.Warn("Insuffiecient reagents with id <%d>, need at least <%d>", reagentId, reagentCount)
      return false
    end
  end

  return true
end

---@param shortClassName string
---@return boolean
function BuffSpell:CanCastOnClass(shortClassName)
  if self.ClassRestrictions == "" then
    return true
  end

  return string.find(self.ClassRestrictions, shortClassName:lower()) ~= nil
end

---@param spawn spawn
---@return boolean
function BuffSpell:CanCastOnspawn(spawn)
  local buffSpell = mq.TLO.Spell(self.Name)

  if (spawn.Distance() or 9999) > (buffSpell.Range()  or 0) then
    return false
  end

  if spawn.Type() == "Corpse" then
    return false
  end

  return true
end

---@param netbot netbot
---@return boolean
function BuffSpell:WillStack(netbot)
  local netbotBuffs = luaUtils.Split(netbot.Buff(), "%s")
  if #netbotBuffs == mq.TLO.Me.MaxBuffSlots() then
    return false
  end

  for _, buffId in ipairs(netbotBuffs) do
    if self.Id == tonumber(buffId) then
      return false
    end

    local buffSpell = mq.TLO.Spell(buffId)
    if buffSpell() and not mq.TLO.Spell(self.Id).WillStack(buffSpell.Name())() then
      return false
    end
  end

  return true
end

return BuffSpell
-- https://stackoverflow.com/questions/64468184/lua-oop-with-metatables-problems-loading-function-from-file

-- https://developpaper.com/lua-multiple-inheritance-code-instance/

-- https://stackoverflow.com/questions/6927364/lua-class-inheritance-problem