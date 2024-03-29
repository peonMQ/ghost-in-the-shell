local mq = require 'mq'
local broadcast = require 'broadcast/broadcast'
local logger = require("knightlinc/Write")
local mqUtils = require 'utils/mqhelpers'
local common = require 'lib/common/common'
local settings = require 'settings/settings'
local assist_state = require 'application/assist_state'

local function doPet()
  if not mq.TLO.Me.Pet.ID() or mq.TLO.Me.Pet.ID() == 0 then
    return
  end

  local query = "id "..assist_state.current_pet_target_id
  if assist_state.current_pet_target_id > 0 and (mq.TLO.SpawnCount(query)() == 0 or mq.TLO.Spawn(query).Type() == "Corpse") then
    mq.cmd("/pet back off")
    assist_state.current_pet_target_id = 0
  elseif assist_state.current_pet_target_id > 0 then
    if not mq.TLO.Me.Pet.Combat() then
      if mqUtils.EnsureTarget(assist_state.current_pet_target_id) then
        mq.cmd("/pet attack")
        mq.delay(5)
        mq.cmd("/pet attack")
      end
    end

    if not mq.TLO.Me.Pet.Combat() then
      logger.Error("Pet not able to engage <%s>", assist_state.current_pet_target_id)
    end

    logger.Debug("Pet has target and hopefully attacking")
    return
  end

  local mainAssist = common.GetMainAssist()
  if not mainAssist then
    return
  end

  local netbot = mq.TLO.NetBots(mainAssist)
  local targetId = netbot.TargetID()
  if not targetId then
    return
  end

  local targetSpawn = mq.TLO.Spawn(targetId)
  local isNPC = targetSpawn.Type() == "NPC"
  local isPet = targetSpawn.Type() == "Pet"
  local hasLineOfSight = targetSpawn.LineOfSight()
  local targetHP = netbot.TargetHP()

  if (not isNPC and not isPet)
     or (targetHP > 0 and targetHP > settings.pet.engage_at)
     or not hasLineOfSight
     or targetSpawn.Distance() > 100 then
      return
  end

  if mqUtils.EnsureTarget(targetId) then
    assist_state.current_pet_target_id = targetId
    mq.cmd("/pet back off")
    mq.delay(5)
    mq.cmd("/pet attack")
    mq.delay(5)
    mq.cmd("/pet attack")
  end
end

return doPet
