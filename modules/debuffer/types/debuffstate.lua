--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')

--- @type Timer
local timer = require('lib/timer')

-- ---@type table<integer, table<string, Timer>>
---@type { [integer]: { [string]: Timer } }
local SpawnDeBuffs = {}

function SpawnDeBuffs:Clean()
  for k,v in ipairs(self) do
    for k2,v2 in ipairs(v) do
      if v2.DurationTimer:IsComplete() then
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

  local spa = spell.SPA()

  self[id][spa] = timer:new(spell.Duration()*6 - 6)
end

---@param id integer
---@param spell spell
---@return boolean
function SpawnDeBuffs:HasDebuff(id, spell)
  if not self[id] then
    return false
  end

  local spa = spell.SPA()
  if not self[id][spa] then
    return false
  end

  return self[id][spa]:IsRunning()
end

return SpawnDeBuffs