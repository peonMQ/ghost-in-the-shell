local mq = require('mq')
local logger = require('knightlinc/Write')
local spell_groups = require('data/spell_groups')
local spell_cures = require('data/spells_cures')

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
  if type(group_name) == 'table' then
    logger.Trace("Erronous type for group_name, got table")
  end

  local class = mq.TLO.Me.Class.ShortName()
  local class_spell_groups = spell_groups[class]
  if not class_spell_groups then
    return nil
  end

  local spell_group = class_spell_groups[group_name] or spell_cures[group_name]
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

--- @param group_name string
--- @return string[]
local function find_group_spells(group_name)
  local class = mq.TLO.Me.Class.ShortName()
  local class_spell_groups = spell_groups[class]
  if not class_spell_groups or not class_spell_groups[group_name] then
    return {}
  end

  local group_spells = {}
  for _, spellName in ipairs(class_spell_groups[group_name]) do
      local spell = find_spell(spellName)
      if spell ~= nil  then
        table.insert(group_spells, spell.Name())
      end
  end

  return group_spells
end

--- @param spell_or_group_name string
--- @return spell|nil
local function find_by_name_or_group(spell_or_group_name)
  local spell = find_spell(spell_or_group_name)
  if spell then
    return spell
  else
    spell = find_group_spell(spell_or_group_name)
    if spell then
      return spell
    end
  end

  return nil
end

---@generic T1, T2
---@param name string
---@param data T1|T2
---@param mapSpellFunc fun(groupname: string, name: string, data: T1):T1
---@param mapItemFunc? fun(name: string, data: T2):T2
---@return T1|T2|nil
local function mapSpellOrItem(name, data, mapSpellFunc, mapItemFunc)
  if mapItemFunc and mq.TLO.FindItem("="..name)() then
      return mapItemFunc(name, data)
    else
      local spell = find_spell(name)
      if spell then
        return mapSpellFunc(name, spell.Name(), data)
      else
        spell = find_group_spell(name)
        if spell then
          return mapSpellFunc(name, spell.Name(), data)
        end
      end
    end

    return nil
end

---@generic T1, T2
---@param spelldata table<string, T1|T2>
---@param mapSpellFunc fun(groupname: string, name: string, data: T1):T1
---@param mapItemFunc? fun(name: string, data: T2):T2
---@return table<string, T1|T2>
local function mapSpellsOrItems(spelldata, mapSpellFunc, mapItemFunc)
  local availableSpells = {}
  for name, value in pairs(spelldata) do
    local spell = mapSpellOrItem(name, value, mapSpellFunc, mapItemFunc)
    if spell then
      availableSpells[name] = spell
    end
  end

  return availableSpells
end

return {
  FindSpell = find_spell,
  FindOrderedSpell = find_ordered_spell,
  FindGroupSpell = find_group_spell,
  FindGroupSpells = find_group_spells,
  FindByNameOrGroup = find_by_name_or_group,
  MapSpellorItem = mapSpellOrItem,
  MapSpellsOrItems = mapSpellsOrItems
}