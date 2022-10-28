--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local broadcast = require('broadcast/broadcast')
local mqUtils = require('utils/mq')
local configLoader = require('utils/configloader')
local common = require('lib/common/common')
local debuffspell = require('modules/debuffer/types/debuffspell')
local debuffState = require('modules/debuffer/types/debuffstate')
local state = require('lib/spells/state')
local castReturnTypes = require('lib/spells/types/castreturn')

---@class MezzConfig
local defaultConfig = {
  Radius = 100,
  MezzSpell = "",
}

local config = configLoader("general.crowdcontrol", defaultConfig)
if config.MezzSpell == "" then
  logger.Error("No mezz spell defined!")
  return function () end
end

local mezzSpell = debuffspell:new(config.MezzSpell, 8, 0, 30, 3)

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
  local mainAssist = common.GetMainAssist()
  if not mainAssist then
    return
  end

  local maTargetId = mq.TLO.NetBots(mainAssist).TargetID()
  local spawnQuery = "npc los targetable radius "..config.Radius
  local mezzTargetCount = mq.TLO.SpawnCount(spawnQuery)()

  --[[
    should we use mq.getFilteredSpawns(predicate) instead? does range really matter...
    local predicate = function (spawn) 
      return spawn.Distance() < config.Radius and spawn.Type() == "NPC" and spawn.Targetable() and spawn.LineOfSight()
    end
    mq.getFilteredSpawns(predicate)
  ]]

  debuffState:Clean()
  for i=1, mezzTargetCount do
    local mezzSpawn = mq.TLO.NearestSpawn(i, spawnQuery)
    if immunities and immunities[mezzSpawn.Name()] then
      logger.Info("[%s] is immune to <%s>, skipping.", mezzSpawn.Name(), mezzSpell.Name)
    elseif maTargetId ~= mezzSpawn.ID() and mqUtils.IsMaybeAggressive(mezzSpawn --[[@as spawn]]) then
      logger.Info("Attempting to mezz [%s] with <%s>.", mezzSpawn.Name(), mezzSpell.Name)
      if mqUtils.EnsureTarget(mezzSpawn.ID()) and mezzSpell:CanCastOnTarget(mq.TLO.Target --[[@as target]]) then
        local castResult = mezzSpell:Cast(checkInterrupt)
        if castResult == castReturnTypes.Immune then
          immunities[mezzSpawn.Name()] = "immune"
        elseif castResult == castReturnTypes.Resisted then
          logger.Info("[%s] resisted <%s> %d times, retrying next run.", mezzSpawn.Name(), mezzSpell.Name, mezzSpell.MaxResists)
        elseif castResult == castReturnTypes.Success then
          logger.Info("[%s] mezzed with <%s>.", mezzSpawn.Name(), mezzSpell.Name)
          broadcast.Success("[%s] mezzed with <%s>.", mezzSpawn.Name(), mezzSpell.Name)
          debuffState:Add(mezzSpawn.ID(), mezzSpell.MQSpell)
        else
          logger.Info("[%s] <%s> mezz failed with. [%s]", mezzSpawn.Name(), mezzSpell.Name, castResult)
        end
      end
    end
  end
end

return doMezz