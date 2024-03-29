local spellGroups = require 'data/spell_groups'

---@param spellGroups table<ClassShortNames, string[]>
---@return table<string, ClassShortNames>
local function extractLookUps(spellGroups)
  local lookups = {}
  for class, groups in pairs(spellGroups) do
    for group, _ in pairs(groups) do
      lookups[group] = class
    end
  end

  return lookups
end

local LookUps = extractLookUps(spellGroups)
return LookUps