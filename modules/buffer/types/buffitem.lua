local mq = require 'mq'
local luaUtils = require 'utils/lua-table'
local item = require 'lib/spells/types/item'

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

local function currentZoneIsNoLevitate()
  local currentZone = mq.TLO.Zone.ShortName()
  return currentZone == "airplane"
end

local function currentZoneIsIndoors()
  local currentZone = mq.TLO.Zone.ShortName()
  return string.find("befallen blackburrow gukbottom guktop neriaka neriakb neriakc paw permafrost qcat runnyeye soldunga soldungb soltemple akanon kaladima kaladimb kedge kurn kaesora", currentZone) ~= nil
end

---@class BuffItem : Item
---@field public Id integer
---@field public Name string
---@field public ItemName string
---@field public ClassRestrictions string
local BuffItem = item:base()

---@param itemName string
---@param classRestrictions string
---@return BuffItem
function BuffItem:new (itemName, classRestrictions)
  self.__index = self
  local o = setmetatable(item:new(itemName), self)
  o.ClassRestrictions = classRestrictions or ""
  return o --[[@as BuffItem]]
end

---@return boolean
function BuffItem:DoesLevitate()
  return string.find("Spirit of Eagle,Flight of Eagles,Levitate,Levitation,Dead Man Floating,Dead Men Floating", self.Name) ~= nil
end

---@return boolean
function BuffItem:DoesIncreaseRunSpeed()
  return string.find("Spirit of Wolf,Spirit of Eagle,Flight of Eagles", self.Name) ~= nil
end

---@return boolean
function BuffItem:CanCast()
  local superCanCast = item.CanCast(self)
  if not superCanCast then
    return false
  end

  -- local wornSlot = buffItem.EffectType()
  -- local effectType = buffItem.EffectType()
  -- ${FindItem[${spellName}].EffectType.Find[worn]}
  -- /varset slotName ${FindItem[${spellName}].WornSlot[1].Name}

  if self:DoesIncreaseRunSpeed() and currentZoneIsIndoors() then
    return false
  end

  if self:DoesLevitate() and currentZoneIsNoLevitate() then
    return false
  end

  return true
end

---@param shortClassName string
---@return boolean
function BuffItem:CanCastOnClass(shortClassName)
  if self.ClassRestrictions == "" then
    return true
  end

  return string.find(self.ClassRestrictions:lower(), shortClassName:lower()) ~= nil
end

---@param spawn spawn
---@return boolean
function BuffItem:CanCastOnspawn(spawn)
  local spell = mq.TLO.Spell(self.Name)

  if spawn.Distance() > spell.Range() then
    return false
  end

  if spawn.Type() == "Corpse" then
    return false
  end

  return true
end

---@param netbot netbot
---@return boolean
function BuffItem:WillStack(netbot)
  local netbotBuffs = luaUtils.Split(netbot.Buff() --[[@as string]], "%s")

  for _, buffId in ipairs(netbotBuffs) do
    if self.Id == tonumber(buffId) then
      return false
    end

    local buffSpell = mq.TLO.Spell(buffId)
    if buffSpell() and not willStack(self.MQSpell, buffSpell) then
      return false
    end
  end

  return true
end

---@return boolean
function BuffItem:WillStackOnMe()
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

return BuffItem
