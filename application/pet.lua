local mq = require('mq')
local broadcast = require('broadcast/broadcast')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local assist = require('core/assist')
local settings = require('settings/settings')
local assist_state = require('application/assist_state')

local function doPet()
  if not mq.TLO.Me.Pet.ID() or mq.TLO.Me.Pet.ID() == 0 then
    return false
  end

  if assist_state.current_pet_target_id == 0 then
    if mq.TLO.Me.Pet.Combat() then
      mq.cmd("/pet back off")
    end

    return false
  end

  local petTarget = mq.TLO.Pet.Target
  if petTarget() and petTarget.ID() ~= assist_state.current_pet_target_id then
    mq.cmd("/pet back off")
    mq.delay(1)
  end

  if not petTarget() then
    if mqUtils.EnsureTarget(assist_state.current_pet_target_id) then
      mq.cmd("/pet attack")
      mq.delay(1)
    end
  elseif petTarget.ID() == assist_state.current_pet_target_id then
    mq.cmd("/pet attack")
    mq.delay(1)
  end

  if not mq.TLO.Me.Pet.Combat() then
    logger.Error("Pet not able to engage <%s>", assist_state.current_pet_target_id)
  else
    logger.Debug("Pet has target and hopefully attacking")
  end

  return false
end

return doPet
