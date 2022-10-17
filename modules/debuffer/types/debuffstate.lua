--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')

--- @type Timer
local timer = require('lib/timer')

-- ---@type table<integer, table<string, Timer>>
---@type { [integer]: { [integer]: { [integer]: { spellID: integer, duration: Timer } } } } 
local SpawnDeBuffs = {}

function SpawnDeBuffs:Clean()
  for k,v in ipairs(self) do
    for k2,v2 in ipairs(v) do
      for k3,v3 in ipairs(v2) do
        if v3.duration:IsComplete() then
          self[k3] = nil
        end
      end

      if not next(v2) then
        self[k2] = nil
      end
    end

    if not next(v) then
      self[k] = nil
    end
  end
end

---@param id integer
---@param spell spell
function SpawnDeBuffs:Add(id, spell)
  if not self[id] then
    self[id] =  {}
  end

  local spellId = spell.ID()
  local category = spell.CategoryID()
  local subCategory = spell.SubcategoryID()

  self[id][category][subCategory] = { spellID = spellId, duration = timer:new(spell.Duration()*6 - 6) }
end

---@param id integer
---@param spell spell
---@return boolean
function SpawnDeBuffs:HasDebuff(id, spell)
  if not self[id] then
    return false
  end

  local category = spell.CategoryID()
  if not self[id][category] then
    return false
  end

  local subCategory = spell.SubcategoryID()
  if not self[id][category][subCategory] then
    return false
  end

  local currentDebuff = self[id][category][subCategory]
  if currentDebuff.duration:IsRunning() then
    if currentDebuff.spellID == spell.ID() then
      return false
    end

    if not mq.TLO.Spell(currentDebuff.spellID).WillStack(spell.Name()) then
      return false
    end
  end

  return true
end

return SpawnDeBuffs