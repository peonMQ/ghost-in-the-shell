--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')
local luaUtils = require 'utils/lua-table'
local spell = require('core/casting/spell')
local zone = require('core/zone')

local SPA_MOVEMENT_RATE = 3
---@param buffSpell spell
---@param currentBuff spell
---@return boolean
local function willStack(buffSpell, currentBuff)
  if buffSpell() and not buffSpell.WillStack(currentBuff.Name())() then
    return false
  end

  if buffSpell.HasSPA(SPA_MOVEMENT_RATE)() then
    for i=1,buffSpell.NumEffects() do
      local buffspellSPA = buffSpell.Attrib(i)()
      if buffspellSPA == SPA_MOVEMENT_RATE and currentBuff.Attrib(i)() == buffspellSPA then
        if buffSpell.Base(i)() > 0 and currentBuff.Base(i)() < 0 then
          return false
        end
      end
    end
  end

  return true
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
  local levitate_spells = "Spirit of Eagle,Flight of Eagles,Levitate,Levitation,Dead Man Floating,Dead Men Floating"
  return string.find(levitate_spells:lower(), self.Name:lower()) ~= nil
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

  if self:DoesIncreaseRunSpeed() and zone.Current.IsIndoors() then
    return false
  end

  if self:DoesLevitate() and zone.Current.IsNoLevitate() then
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
function BuffSpell:CanCastOnSpawn(spawn)
  if spawn.ID() == mq.TLO.Me.ID() and self.MQSpell.TargetType() == "Self" then
    return true
  end

  if (spawn.Distance() or 9999) > (self.MQSpell.Range() or 0) then
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

    local buffSpell = mq.TLO.Spell(buffId) --[[@as spell]]
    if buffSpell() and not willStack(self.MQSpell, buffSpell) then
      return false
    end
  end

  return true
end

---@return boolean
function BuffSpell:WillStackOnMe()
  if self.MQSpell.DurationWindow() == 0 then
    if mq.TLO.Me.Buff(self.Name)() then
      return false
    end

    for i=1,mq.TLO.Me.MaxBuffSlots() do
      local currentBuff = mq.TLO.Me.Buff(i) --[[@as buff]]
      if currentBuff() and not willStack(self.MQSpell, currentBuff) then
        return false
      end
    end
  elseif self.MQSpell.DurationWindow() == 1 then
    if mq.TLO.Me.Song(self.Name)() then
      return false
    end

    for i=1,12 do
      local currentBuff = mq.TLO.Me.Song(i) --[[@as buff]]
      if currentBuff() and not willStack(self.MQSpell, currentBuff) then
        return false
      end
    end
  end

  return true
end

return BuffSpell
-- https://stackoverflow.com/questions/64468184/lua-oop-with-metatables-problems-loading-function-from-file

-- https://developpaper.com/lua-multiple-inheritance-code-instance/

-- https://stackoverflow.com/questions/6927364/lua-class-inheritance-problem