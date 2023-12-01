local mq = require 'mq'
local logger = require("knightlinc/Write")
local mqUtils = require 'utils/mqhelpers'
local common = require 'lib/common/common'
local settings = require 'settings/settings'
local assist_state = require 'application/assist_state'
local state = require 'lib/spells/state'

local next = next

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
  local nukes = settings.assist.nukes[assist_state.spell_set]
  if not next(nukes or {}) then
    logger.Debug("No nuke for <%s>", assist_state.spell_set)
    return
  end

  -- might want to fetch nuke based on target type for 'Undead' and 'Summoned'
  local nukeSpell = nil
  for _, nuke in pairs(nukes) do
    if nuke:MemSpell() and mq.TLO.Me.SpellReady(nuke.Name)() then
      logger.Debug("Nuke chosen <%s>", nuke.Name)
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
     or (targetHP > 0 and targetHP > settings.assist.engage_at)
     or not hasLineOfSight
     or not nukeSpell:CanCastOnspawn(targetSpawn) then
      return
  end

  if mqUtils.EnsureTarget(targetId) and nukeSpell:CanCast() then
    nukeSpell:Cast(checkInterrupt)
  end
end

return doNuking