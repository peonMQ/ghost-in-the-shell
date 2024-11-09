--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local mqUtils = require('utils/mqhelpers')
local spawnsearchfilter = require('core/spawnsearchfilter')
local assist = require('core/assist')
local timer = require('core/timer')
local state = require('application/casting/casting_state')
local castReturnTypes = require('core/casting/castreturn')
local spell_finder = require('application/casting/spell_finder')
local spells_mesmerize = require('data/spells_mesmerize')
local settings = require('settings/settings')
local assist_state = require('application/assist_state')
local debuffspell = require('core/casting/debuffs/debuffspell')
local repository = require('application/debuffing/debuffRepository')

-- possible mezz animations
-- 26, 32, 71, 72, 110, 111
-- possible Aggro Animations
-- 5,8,12,17,18,32,42,44,80,106,129,144

local maxRadius = 100
local cleanTimer = timer:new(60)
local immunities = {}

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

  local mainAssist = assist.GetMainAssist()
  if not mainAssist then
    return
  end

  local targetId = mq.TLO.NetBots(mainAssist).TargetID()
  if targetId == target.ID() then
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

local function doChainStun()
  -- progress PBAE
  if assist.pbaoe_active then
    local nearbyPBAEilter = "npc radius 60 zradius 50 los"
    if mq.TLO.SpawnCount(nearbyPBAEilter)() == 0 then
      logger.Debug("NPC filter for PBAoE failed.")
      return false
    end

    for _, aoe_stunn_spell in ipairs(settings.assist.aoe_stuns) do
      if aoe_stunn_spell:MemSpell() and mq.TLO.Me.SpellReady(aoe_stunn_spell.Name)() then
        logger.Debug("PBAoE stun chosen <%s>", aoe_stunn_spell.Name)
        if aoe_stunn_spell:CanCast() then
          aoe_stunn_spell:Cast(checkInterruptPBAoE)
          return true
        end
      end
    end
  end

  return false
end

---@return boolean
local function doMezz()
  if assist.IsOrchestrator() then
    return false
  end

  if assist.pbaoe_active then
    doChainStun()
    return false
  end

  if not assist_state.crowd_control_mode then
    return false
  end

  local mezz_spell_group = spells_mesmerize[mq.TLO.Me.Class.ShortName()] and spells_mesmerize[mq.TLO.Me.Class.ShortName()][assist_state.crowd_control_mode]
  if not mezz_spell_group then
    return false
  end

  local mainAssist = assist.GetMainAssist()
  if not mainAssist then
    return false
  end

  local maTargetId = mq.TLO.NetBots(mainAssist).TargetID()
  local spawnQueryFilter = spawnsearchfilter:new()
                                            :IsNPC()
                                            :HasLineOfSight()
                                            :IsTargetable()
                                            :WithinRadius(maxRadius).filter
  local mezzTargetCount = mq.TLO.SpawnCount(spawnQueryFilter)()

  if mezzTargetCount <= 0 then
    return false
  end

  local class_spell = spell_finder.FindGroupSpell(mezz_spell_group)
  if not class_spell then
    logger.Error("No mezz spell defined!")
    return false
  end

  local mezz_spell = debuffspell:new(class_spell.Name(), settings:GetDefaultGem(mezz_spell_group), 0, 30, 3)

  for i=1, mezzTargetCount do
    local mezzSpawn = mq.TLO.NearestSpawn(i, spawnQueryFilter)
    local mezzName = mezzSpawn.Name()
    if immunities and immunities[mezzName] then
      logger.Info("[%s] is immune to <%s>, skipping.", mezzName, mezz_spell.Name)
    elseif maTargetId ~= mezzSpawn.ID() and mqUtils.IsMaybeAggressive(mezzSpawn --[[@as spawn]]) then
      if mqUtils.EnsureTarget(mezzSpawn.ID()) and mezz_spell:CanCastOnTarget(mq.TLO.Target --[[@as target]]) and mezz_spell.MQSpell.Max(1)() >= mezzSpawn.Level() then
        logger.Info("Attempting to mezz [%s] with <%s>.", mezzName, mezz_spell.Name)
        local castResult = mezz_spell:Cast(checkInterrupt)
        if castResult == castReturnTypes.Immune then
          immunities[mezzName] = "immune"
        elseif castResult == castReturnTypes.Resisted then
          logger.Info("[%s] resisted <%s> %d times, retrying next run.", mezzName, mezz_spell.Name, mezz_spell.MaxResists)
        elseif castResult == castReturnTypes.Success then
          logger.Info("[%s] mezzed with <%s>.", mezzName, mezz_spell.Name)
          broadcast.SuccessAll("[%s] mezzed with <%s>.", broadcast.ColorWrap(mezzName, 'Maroon'), broadcast.ColorWrap(mezz_spell.Name, 'Blue'))
          repository.Insert(mezzSpawn.ID(), mezz_spell)
        else
          logger.Info("[%s] <%s> mezz failed with. [%s]", mezzName, mezz_spell.Name, castResult)
        end
      end
    end
  end

  if cleanTimer:IsComplete() then
    repository.Clean()
    cleanTimer:Reset()
  end

  return false
end

return doMezz