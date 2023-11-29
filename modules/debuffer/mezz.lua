--- @type Mq
local mq = require 'mq'
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local mqUtils = require 'utils/mqhelpers'
local spawnsearchparams = require 'lib/spawnsearchparams'
local common = require 'lib/common/common'
local timer = require 'lib/timer'
local state = require 'lib/spells/state'
local castReturnTypes = require 'lib/spells/types/castreturn'
local spell_finder = require 'lib/spells/spell_finder'
local spells_mezmerize = require 'data/spells_mezmerize'
local settings = require 'settings/settings'
local assist_state = require 'settings/assist_state'
local debuffspell = require 'modules/debuffer/types/debuffspell'
local repository = require 'modules/debuffer/types/debuffRepository'

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
    state.interrupt()
  end

  if target.Type() == "Corpse" then
    state.interrupt()
  end

  local mainAssist = common.GetMainAssist()
  if not mainAssist then
    return
  end

  local targetId = mq.TLO.NetBots(mainAssist).TargetID()
  if targetId == target.ID() then
    state.interrupt()
  end
end

local function doMezz()
  if not assist_state.mezz_mode then
    return
  end

  local mezz_spell_group = spells_mezmerize[mq.TLO.Me.Class.ShortName()] and spells_mezmerize[mq.TLO.Me.Class.ShortName()][assist_state.mezz_mode]
  if not mezz_spell_group then
    return
  end

  local mainAssist = common.GetMainAssist()
  if not mainAssist then
    return
  end

  local maTargetId = mq.TLO.NetBots(mainAssist).TargetID()
  local spawnQueryFilter = spawnsearchparams:new()
                                            :IsNPC()
                                            :HasLineOfSight()
                                            :IsTargetable()
                                            :WithinRadius(maxRadius).filter
  local mezzTargetCount = mq.TLO.SpawnCount(spawnQueryFilter)()

  if mezzTargetCount <= 0 then
    return
  end

  local class_spell = spell_finder.FindGroupSpell(mezz_spell_group)
  if not class_spell then
    logger.Error("No mezz spell defined!")
    return
  end

  local mezz_spell = debuffspell:new(class_spell.Name(), settings:GetDefaultGem(mezz_spell_group), 0, 30, 3)

  for i=1, mezzTargetCount do
    local mezzSpawn = mq.TLO.NearestSpawn(i, spawnQueryFilter)
    local mezzName = mezzSpawn.Name()
    if immunities and immunities[mezzName] then
      logger.Info("[%s] is immune to <%s>, skipping.", mezzName, mezz_spell.Name)
    elseif maTargetId ~= mezzSpawn.ID() and mqUtils.IsMaybeAggressive(mezzSpawn --[[@as spawn]]) then
      if mqUtils.EnsureTarget(mezzSpawn.ID()) and mezz_spell:CanCastOnTarget(mq.TLO.Target --[[@as target]]) then
        logger.Info("Attempting to mezz [%s] with <%s>.", mezzName, mezz_spell.Name)
        local castResult = mezz_spell:Cast(checkInterrupt)
        if castResult == castReturnTypes.Immune then
          immunities[mezzName] = "immune"
        elseif castResult == castReturnTypes.Resisted then
          logger.Info("[%s] resisted <%s> %d times, retrying next run.", mezzName, mezz_spell.Name, mezz_spell.MaxResists)
        elseif castResult == castReturnTypes.Success then
          logger.Info("[%s] mezzed with <%s>.", mezzName, mezz_spell.Name)
          broadcast.SuccessAll("[%s] mezzed with <%s>.", mezzName, mezz_spell.Name)
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
end

return doMezz