--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local assist = require('core/assist')
local settings = require('settings/settings')
local events = require('application/meleeing/events')
local assist_state = require('application/assist_state')
local npc_belly_casters = require('data/npc_belly_casters')
local movement = require('core/movement')

local function setAssistTarget()
  if assist_state.current_target_id > 0 then
    local targetSpawn = mq.TLO.Spawn(assist_state.current_target_id)
    if not targetSpawn() or targetSpawn.Type() == "Corpse" then
      assist_state:Reset('current_target_id')
    end
  else
    local targetSpawn = assist.GetMainAssistTarget(settings.assist.engage_at)
    if targetSpawn then
      assist_state.current_target_id = targetSpawn.ID()
    end
  end
end

local function setAssistTargetPet()
  if not mq.TLO.Me.Pet.ID() or mq.TLO.Me.Pet.ID() == 0 or not settings.pet then
    return
  end

  if assist_state.current_pet_target_id > 0 then
    local targetSpawn = mq.TLO.Spawn(assist_state.current_pet_target_id)
    if not targetSpawn() or targetSpawn.Type() == "Corpse" then
      assist_state:Reset('current_pet_target_id')
    end
  else
    local targetSpawn = assist.GetMainAssistTarget(settings.pet.engage_at)
    if targetSpawn then
      assist_state.current_pet_target_id = targetSpawn.ID()
    end
  end
end

local function moveBellyCasterTarget()
  if settings.assist.type ~= nil or assist_state.current_target_id == 0 or mq.TLO.Me.Combat() then
    return
  end

  local targetSpawn = mq.TLO.Spawn(assist_state.current_target_id)
  if not targetSpawn() or not npc_belly_casters[targetSpawn.CleanName()] then
    return
  end

  local stickDistance = math.floor(targetSpawn.MaxRangeTo()* 0.75)
  stickDistance = math.min(stickDistance, 25)
  if targetSpawn.Distance3D() > stickDistance then
    movement.MoveToLoc(targetSpawn.X(), targetSpawn.Y(), targetSpawn.Z(), 5, stickDistance)
  end
end

local function onTick()
  if assist.IsOrchestrator() then
    return false
  end

  setAssistTarget()
  setAssistTargetPet()
  moveBellyCasterTarget()
  return false
end

return onTick