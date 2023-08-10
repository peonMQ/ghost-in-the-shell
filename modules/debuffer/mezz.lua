--- @type Mq
local mq = require 'mq'
local logger = require 'utils/logging'
local broadcast = require 'broadcast/broadcast'
local mqUtils = require 'utils/mqhelpers'
local configLoader = require 'utils/configloader'
local debugUtils = require 'utils/debug'
local spawnsearchparams = require 'lib/spawnsearchparams'
local common = require 'lib/common/common'
local state = require 'lib/spells/state'
local castReturnTypes = require 'lib/spells/types/castreturn'
local debuffspell = require 'modules/debuffer/types/debuffspell'
local repository = require 'modules/debuffer/types/debuffRepository'

-- possible mezz animations
-- 26, 32, 71, 72, 110, 111
-- possible Aggro Animations
-- 5,8,12,17,18,32,42,44,80,106,129,144

--- @type Timer
local timer = require 'lib/timer'

---@class MezzConfig
local defaultConfig = {
  DoCrowdControl = false,
  Radius = 100,
  MezzSpell = "",
}

local config = configLoader("general.crowdcontrol", defaultConfig)
local cleanTimer = timer:new(60)
local mezzSpell = nil
local immunities = {}
if config.MezzSpell ~= "" then
  mezzSpell = debuffspell:new(config.MezzSpell, 8, 0, 30, 3)
end

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
  if not config.DoCrowdControl then
    return
  end

  if not mezzSpell then
    logger.Error("No mezz spell defined!")
    config.DoCrowdControl = false
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
                                            :WithinRadius(config.Radius).filter
  local mezzTargetCount = mq.TLO.SpawnCount(spawnQueryFilter)()

  var mezzName = mezzSpawn.Name()
  for i=1, mezzTargetCount do
    local mezzSpawn = mq.TLO.NearestSpawn(i, spawnQueryFilter)
    if immunities and immunities[mezzName] then
      logger.Info("[%s] is immune to <%s>, skipping.", mezzName, mezzSpell.Name)
    elseif maTargetId ~= mezzSpawn.ID() and mqUtils.IsMaybeAggressive(mezzSpawn --[[@as spawn]]) then
      if mqUtils.EnsureTarget(mezzSpawn.ID()) and mezzSpell:CanCastOnTarget(mq.TLO.Target --[[@as target]]) then
        logger.Info("Attempting to mezz [%s] with <%s>.", mezzName, mezzSpell.Name)
        local castResult = mezzSpell:Cast(checkInterrupt)
        if castResult == castReturnTypes.Immune then
          immunities[mezzName] = "immune"
        elseif castResult == castReturnTypes.Resisted then
          logger.Info("[%s] resisted <%s> %d times, retrying next run.", mezzName, mezzSpell.Name, mezzSpell.MaxResists)
        elseif castResult == castReturnTypes.Success then
          logger.Info("[%s] mezzed with <%s>.", mezzName, mezzSpell.Name)
          broadcast.Success("[%s] mezzed with <%s>.", mezzName, mezzSpell.Name)
          repository.Insert(mezzSpawn.ID(), mezzSpell)
        else
          logger.Info("[%s] <%s> mezz failed with. [%s]", mezzName, mezzSpell.Name, castResult)
        end
      end
    end
  end

  if cleanTimer:IsComplete() then
    repository.Clean()
    cleanTimer:Reset()
  end
end

local boolParam = {["1"] = true, ["true"] = true, ["on"] = true, ["0"] = false, ["false"] = false, ["off"] = false}

---@param toggle string
local function doCrowdControl(toggle)
  if not mezzSpell then
    return
  end

  if boolParam[toggle:lower()] == nil then
    return
  end

  config.DoCrowdControl = boolParam[toggle:lower()]
  if not config.DoCrowdControl then
    broadcast.Error("%s is no longer doing crowd control", mq.TLO.Me.Name())
  else
    broadcast.Success("%s is now doing crowd control", mq.TLO.Me.Name())
  end
end


mq.unbind('/docc')
mq.bind("/docc", doCrowdControl)

return doMezz