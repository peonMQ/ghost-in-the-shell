--- @type Mq
local mq = require 'mq'
local logger = require("knightlinc/Write")
local plugin = require 'utils/plugins'
local mqUtils = require 'utils/mqhelpers'
local common = require 'lib/common/common'
local spawnsearchparams = require 'lib/spawnsearchparams'
local state = require 'lib/spells/state'
local numberUtils = require 'lib/numberutils'
local settings = require 'settings/settings'

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
  if numberUtils.IsLargerThan(target.Distance(), spell.Range()) then
    state.interrupt(spellId)
    return
  end
end

local function checkCure(spell)
  for i=1,mq.TLO.NetBots.Counts() do
    local name = mq.TLO.NetBots.Client(i)()
    local netbot = mq.TLO.NetBots(name) --[[@as netbot]]
    if spell:CanCastOnNetBot(netbot) then
      if mqUtils.EnsureTarget(netbot.ID()) then
        logger.Info("Cure netbot with '%s' <%s>[%d]", spell.MQSpell.Name(), mq.TLO.Target.Name(), mq.TLO.Target.PctHPs())
        spell:Cast(checkInterrupt)
      end
    end
  end
end

local function doCuring()
  if common.IsOrchestrator() then
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

  for _, curespell in ipairs(settings.cures) do
    checkCure(curespell)
  end

end

return doCuring

