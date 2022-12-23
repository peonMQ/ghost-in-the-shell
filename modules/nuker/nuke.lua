--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local mqUtils = require('utils/mqhelpers')
local luautils = require('utils/lua-table')
local enum = require('utils/stringenum')
local common = require('lib/common/common')
local commonConfig = require('lib/common/config')
local state = require('lib/spells/state')
local config = require('modules/nuker/config')
---@type Timer
local timer = require('lib/timer')

local next = next

local validResistTypes = enum({
  -- "Chromatic",
  -- "Corruption",
  "Cold",
  "Disease",
  "Fire",
  "Magic",
  "Poison",
  -- "Unresistable",
  -- "Prismatic"
})

local function checkInterrupt(spellId)
  local target = mq.TLO.Target
  if not target() then
    state.interrupt()
  end

  if target.Type() == "Corpse" then
    state.interrupt()
  end
  
  local spell = mq.TLO.Spell(spellId)
  if not target.Distance() or target.Distance() > spell.Range() then
    state.interrupt()
  end
end

local function doNuking()
  if not next(config.CurrentLineup) then
    return
  end

  -- might want to fetch nuke based on target type for 'Undead' and 'Summoned'
  local nukeSpell = nil
  for i=1, #config.CurrentLineup do
    local nuke = config.Nukes[i]
    if mq.TLO.Me.SpellReady(nuke.Name)() then
      nukeSpell = nuke
      break
    end
  end

  if not nukeSpell then
    logger.Debug("No nuke ready for casting")
    return
  end

  local mainAssist = common.GetMainAssist()
  if not mainAssist then
    return
  end

  local netbot = mq.TLO.NetBots(mainAssist)
  local targetId = netbot.TargetID()
  if targetId == "NULL" then
    return
  end

  local targetSpawn = mq.TLO.Spawn(targetId)
  local isNPC = targetSpawn.Type() == "NPC"
  local isPet = targetSpawn.Type() == "Pet"
  local hasLineOfSight = targetSpawn.LineOfSight()
  local targetHP = netbot.TargetHP()

  if (not isNPC and not isPet)
     or (targetHP > 0 and targetHP > commonConfig.AssistPct)
     or not hasLineOfSight
     or not nukeSpell:CanCastOnspawn(targetSpawn) then
      return
  end

  if mqUtils.EnsureTarget(targetId) and nukeSpell:CanCast() then
    nukeSpell:Cast(checkInterrupt)
  end
end

local function setNukeLineup(resistType)
  if not validResistTypes[resistType] then
    logger.Info("Lineup <%s> does not a valid resist type. Valid keys are: [%s]", resistType, luautils.GetKeysSorted(validResistTypes))
    return
  end

  if not next(config.Nukes) then
    logger.Warn("No nukes defined in config.")
    return
  end

  local newLineUp = {}
  for i=1, #config.Nukes do
    local nuke = config.Nukes[i]
    local spell = mq.TLO.Spell(nuke.Id)
    if validResistTypes[spell.ResistType()] and spell.ResistType() == resistType then
      table.insert(newLineUp, nuke)
    end
  end

  if not next(newLineUp) then
    logger.Warn("Unable to find any nukes in config matching resist type <%s>.", resistType)
    return
  end

  config.CurrentLineup = newLineUp
end


local function clearNukeLineup()
  config.CurrentLineup = config.Nukes
end

local function createAliases()
  mq.unbind('/setlineup')
  mq.unbind('/clearlineup')
  mq.bind("/setlineup", setNukeLineup)
  mq.bind("/clearlineup", clearNukeLineup)
end

createAliases()

return doNuking