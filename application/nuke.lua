local mq = require('mq')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local assist = require('core/assist')
local settings = require('settings/settings')
local assist_state = require('application/assist_state')
local state = require('application/casting/casting_state')

local next = next

local function checkInterrupt(spellId)
  local target = mq.TLO.Target
  if not target() then
    state.interrupt(spellId)
    return
  end

  if target.Type() == "Corpse" then
    state.interrupt(spellId)
    return
  end

  local spell = mq.TLO.Spell(spellId)
  if not target.Distance() or target.Distance() > spell.Range() then
    state.interrupt(spellId)
    return
  end
end

local function checkInterruptPBAoE(spellId)
  if not assist_state.pbaoe_active then
    state.interrupt(spellId)
    return
  end
end

---@param nuke_set table<string, NukeSpell>
---@return NukeSpell|nil
local function getNukeSpell(nuke_set)
  -- might want to fetch nuke based on target type for 'Undead' and 'Summoned'
  local highest_level_spell = nil
  for _, nuke in pairs(nuke_set) do
    if nuke:MemSpell() and mq.TLO.Me.SpellReady(nuke.Name)() and (not highest_level_spell or nuke.MQSpell.Level() > highest_level_spell.MQSpell.Level()) then
      logger.Debug("Nuke chosen <%s>", nuke.Name)
      highest_level_spell = nuke
    end
  end

  return highest_level_spell
end

local function doPBAoE()
  -- progress PBAE
  if assist.pbaoe_active then
    local nearbyPBAEilter = "npc radius 60 zradius 50 los"
    if mq.TLO.SpawnCount(nearbyPBAEilter)() == 0 then
      logger.Debug("NPC filter for PBAoE failed.")
      return
    end

    for _, pbaoe_spell in ipairs(settings.assist.pbaoe) do
      if pbaoe_spell:MemSpell() then
        logger.Debug("PBAoE chosen <%s>", pbaoe_spell.Name)
        if pbaoe_spell:CanCast() then
          pbaoe_spell:Cast(checkInterruptPBAoE)
          return
        end
      end
    end
  end
end

local function doNuking()
  if assist.IsOrchestrator() then
    return
  end

  if assist.pbaoe_active then
    doPBAoE()
    return
  end

  local nukes = settings.assist.nukes[assist_state.spell_set]
  if not next(nukes or {}) then
    logger.Debug("No nuke for <%s>", assist_state.spell_set)
    return
  end

  if assist_state.current_target_id == 0 then
    return
  end

  local nukeSpell = getNukeSpell(nukes)
  if not nukeSpell then
    logger.Debug("No nuke ready for casting")
    return
  end

  local targetSpawn = mq.TLO.Spawn(assist_state.current_target_id)
  if not targetSpawn() or not nukeSpell:CanCastOnspawn(targetSpawn --[[@as spawn]]) then
    return
  end

  if mqUtils.EnsureTarget(targetSpawn.ID()) and nukeSpell:CanCast() then
    nukeSpell:Cast(checkInterrupt)
  end
end

return doNuking