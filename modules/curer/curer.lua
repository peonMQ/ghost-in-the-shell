--- @type Mq
local mq = require 'mq'
local logger = require 'utils/logging'
local plugin = require 'utils/plugins'
local mqUtils = require 'utils/mqhelpers'
local spawnsearchparams = require 'lib/spawnsearchparams'
local state = require 'lib/spells/state'
local numberUtils = require 'lib/numberutils'
local config = require 'modules/curer/config'

local function checkInterrupt(spellId)
  local target = mq.TLO.Target
  if not target() then
    state.interrupt()
  end

  if target.Type() == "Corpse" then
    state.interrupt()
  end

  local spell = mq.TLO.Spell(spellId)
  if numberUtils.IsLargerThan(target.Distance(), spell.Range()) then
    state.interrupt()
  end
end

local function checkCurePoison()
  local spell = config.CurePoison
  if not spell then
    logger.Debug("No CurePoison.")
    return
  end

  for i=1,mq.TLO.NetBots.Counts() do
    local name = mq.TLO.NetBots.Client(i)()
    local netbot = mq.TLO.NetBots(name) --[[@as netbot]]
    if spell:CanCastOnNetBot(netbot) then
      if mqUtils.EnsureTarget(netbot.ID()) then
        logger.Info("Cure disease netbot '%s' <%s>[%d]", spell.MQSpell.Name(), mq.TLO.Target.Name(), mq.TLO.Target.PctHPs())
        spell:Cast(checkInterrupt)
      end
    end
  end
end

local function checkCureDisease()
  local spell = config.CureDisease
  if not spell then
    logger.Debug("No CureDisease.")
    return
  end

  for i=1,mq.TLO.NetBots.Counts() do
    local name = mq.TLO.NetBots.Client(i)()
    local netbot = mq.TLO.NetBots(name) --[[@as netbot]]
    if spell:CanCastOnNetBot(netbot) then
      if mqUtils.EnsureTarget(netbot.ID()) then
        logger.Info("Cure disease netbot '%s' <%s>[%d]", spell.MQSpell.Name(), mq.TLO.Target.Name(), mq.TLO.Target.PctHPs())
        spell:Cast(checkInterrupt)
      end
    end
  end
end

local function doCuring()
  if plugin.IsLoaded("mq2netbots") == false then
    logger.Debug("mq2netbots is not loaded")
    return
  end

  if mq.TLO.NetBots.Counts() < 1 then
    logger.Debug("No Nebots clients.")
    return
  end

  local spawnQueryFilter = spawnsearchparams:new()
                                            :IsNPC()
                                            :HasLineOfSight()
                                            :IsTargetable()
                                            :WithinRadius(200).filter
  local npcsInCampCount = mq.TLO.SpawnCount(spawnQueryFilter)()
  if npcsInCampCount > 0 then
    return
  end

  checkCurePoison()
  checkCureDisease()
end

return doCuring

