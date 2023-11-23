local mq = require('mq')
local logger = require("knightlinc/Write")
local spell_groups = require 'data/spell_groups'

--- @param spell_group string[]
local function find_spell(spell_group)
  local spell = nil
  for _, spellName in ipairs(spell_group) do
      local spellSlot = mq.TLO.Me.Book(mq.TLO.Spell(spellName).RankName())
      if spellSlot() then
        local spell = mq.TLO.Me.Book((spellSlot()))
        if spell() ~= nil and (not spell or spell.Level() > spell.Level()) then
          spell = spell --[[@as spell]]
          logger.Debug("Found new/upgraded spell in book: [%s] - %s", spell.Level(), spellName)
        end
      else
          logger.Debug("Spell not in book: %s", spellName)
      end
  end

  return spell
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

  local spell = find_spell(spell_group)
  if not spell then
    logger.Warn("No spell found for spellgroup <%s> with class <%s>.", group_name, class)
    return nil
  end

  return spell
end

return {
  FindSpell = find_spell,
  FindGroupSpell = find_group_spell,
}