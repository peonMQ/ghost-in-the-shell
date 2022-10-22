--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local broadcast = require('broadcast/broadcast')
local mqUtils = require('utils/mq')
local common = require('lib/common/common')
local state = require('lib/spells/state')
local castReturnTypes = require('lib/spells/types/castreturn')
local config = require('modules/debuffer/config')
local repository = require('modules/debuffer/types/debuffRepository')

--- @type Timer
local timer = require('lib/timer')

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
end

local function doDebuffs()
  local mainAssist = common.GetMainAssist()
  if not mainAssist then
    return
  end

  local targetId = mq.TLO.NetBots(mainAssist).TargetID()
  if not targetId then
    return
  end

  local targetSpawn = mq.TLO.Spawn(targetId)
  local isNPC = targetSpawn.Type() == "NPC"
  local isPet = targetSpawn.Type() == "Pet"
  local hasLineOfSight = targetSpawn.LineOfSight()

  if (not isNPC and not isPet)
     or not hasLineOfSight then
      return
  end

  if cleanTimer:IsComplete() then
    repository.Clean()
    cleanTimer = cleanTimer:new(60)
  end

  for key, debuffSpell in pairs(config.DeBuffs) do
    logger.Debug("Debuffing with <%s>", debuffSpell.Name)
    if debuffSpell:CanCast() then
      local spell = mq.TLO.Spell(debuffSpell.Id)
      if spell.SpellType() == "Detrimental" then
        local spellImmunity = immunities[debuffSpell.Id]
        if spellImmunity and spellImmunity[targetSpawn.Name()] then
          logger.Info("[%s] is immune to <%s>, skipping.", targetSpawn.Name(), debuffSpell.Name)
        elseif mqUtils.EnsureTarget(targetSpawn.ID()) and debuffSpell:CanCastOnTarget(mq.TLO.Target --[[@as target]]) then
          local castResult = debuffSpell:Cast(checkInterrupt)
          if castResult == castReturnTypes.Immune then
            spellImmunity[targetSpawn.Name()] = "immune"
          elseif castResult == castReturnTypes.Resisted then
            logger.Info("[%s] resisted <%s> %d times, retrying next run.", targetSpawn.Name(), debuffSpell.Name, debuffSpell.MaxResists)
          elseif castResult == castReturnTypes.Success then
            logger.Info("[%s] debuffed with <%s>.", targetSpawn.Name(), debuffSpell.Name)
            broadcast.Success("[%s] debuffed with <%s>.", targetSpawn.Name(), debuffSpell.Name)
            repository.Insert(targetSpawn.ID(), debuffSpell)
          else
            logger.Info("[%s] <%s> debuff failed with. [%s]", targetSpawn.Name(), debuffSpell.Name, castResult)
          end
        end
      end
    end
  end
end

return doDebuffs