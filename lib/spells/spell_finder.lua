local mq = require('mq')
local logger = require("knightlinc/Write")
local spell_groups = require 'data/spell_groups'

---@param spell_name string
---@return spell?
local function find_spell(spell_name)
  local spell = mq.TLO.Spell(spell_name)
  if not spell() then
    logger.Debug("Spell doest not exist: %s", spell_name)
    return nil
  end

  local spellSlot = mq.TLO.Me.Book(spell.RankName.Name())
  if spellSlot() then
    return mq.TLO.Me.Book(spellSlot()) --[[@as spell]]
  else
      logger.Debug("Spell not in book: %s", spell.RankName.Name())
  end

  return nil
end

--- @param group_spells string[]
--- @return spell?
local function find_ordered_spell(group_spells)
  local highest_level_spell = nil
  for _, spellName in ipairs(group_spells) do
      local spell = find_spell(spellName)
      if spell ~= nil and (not highest_level_spell or spell.Level() > highest_level_spell.Level()) then
        logger.Debug("Found new/upgraded spell in book: [%s] - %s", spell.Level(), spell.Name())
        highest_level_spell = spell --[[@as spell]]
      end
  end

  return highest_level_spell
end

--- @param group_name string
--- @return spell?, string?
local function find_group_spell(group_name)
  local class = mq.TLO.Me.Class.ShortName()
  local class_spell_groups = spell_groups[class]
  if not class_spell_groups then
    return nil
  end

  local spell_group = class_spell_groups[group_name]
  if not spell_group then
    logger.Error("Spellgroup <%s> for class <%s> not found.", group_name, class)
    mq.cmd("/beep")
    return nil
  end

  local spell = find_ordered_spell(spell_group)
  if not spell then
    logger.Warn("No spell found for spellgroup <%s> with class <%s>.", group_name, class)
    return nil
  end

  return spell
end

return {
  FindSpell = find_spell,
  FindOrderedSpell = find_ordered_spell,
  FindGroupSpell = find_group_spell,
}