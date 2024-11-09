local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local mqUtils = require('utils/mqhelpers')
local assist = require('core/assist')
local state = require('application/casting/casting_state')
local castReturnTypes = require('core/casting/castreturn')
local settings = require('settings/settings')
local repository = require('application/debuffing/debuffRepository')
local timer = require('core/timer')
local assist_state = require('application/assist_state')

local cleanTimer = timer:new(300)

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
end

---@return boolean
local function doDebuffs()
  if assist.IsOrchestrator() then
    if cleanTimer:IsComplete() then
      repository.Clean()
      cleanTimer:Reset()
    end

    return false
  end

  if assist_state.current_target_id == 0 then
    return false
  end

  if not assist_state.debuffs_active then
    return false
  end

  local targetSpawn = mq.TLO.Spawn(assist_state.current_target_id)
  if not targetSpawn() then
    return false
  end

  for _, debuffSpell in pairs(settings.assist.debuffs) do
    if debuffSpell:CanCast() then
      local spell = debuffSpell.MQSpell
      if spell.SpellType() == "Detrimental" then
        local spellImmunity = immunities[debuffSpell.Id]
        if spellImmunity and spellImmunity[targetSpawn.Name()] then
          logger.Debug("[%s] is immune to <%s>, skipping.", targetSpawn.Name(), debuffSpell.Name)
        elseif mqUtils.EnsureTarget(targetSpawn.ID()) and debuffSpell:CanCastOnTarget(mq.TLO.Target --[[@as target]]) then
          logger.Debug("Debuffing with <%s>", debuffSpell.Name)
          local castResult = debuffSpell:Cast(checkInterrupt)
          if castResult == castReturnTypes.Immune then
            spellImmunity[targetSpawn.Name()] = "immune"
          elseif castResult == castReturnTypes.Resisted then
            logger.Info("[%s] resisted <%s> %d times, retrying next run.", targetSpawn.Name(), debuffSpell.Name, debuffSpell.MaxResists)
          elseif castResult == castReturnTypes.Success then
            logger.Info("[%s] debuffed with <%s>.", targetSpawn.Name(), debuffSpell.Name)
            broadcast.SuccessAll("[%s] debuffed with <%s>.", targetSpawn.Name(), debuffSpell.Name)
            repository.Insert(targetSpawn.ID(), debuffSpell)
          else
            logger.Info("[%s] <%s> debuff failed with. [%s]", targetSpawn.Name(), debuffSpell.Name, castResult)
            broadcast.FailAll("[%s] <%s> debuff failed with. [%s]", targetSpawn.Name(), debuffSpell.Name, castResult)
          end

          return true
        end
      end
    end
  end

  return false
end

return doDebuffs