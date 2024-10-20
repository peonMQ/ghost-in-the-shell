local logger = require('knightlinc/Write')
local mqutil = require('utils/mqhelpers')
local movement = require('core/movement')
local app_state = require('app_state')

local function moveBackToCamp()
  if mqutil.NPCInRange(100) then
    return
  end

  local campLoc = app_state.CampLoc
  if not campLoc then
    return
  end

  movement.MoveToLoc(campLoc.x, campLoc.y, campLoc.z)
end

---@param loc ImVec4|nil
local function setCamp(loc)
  app_state.CampLoc = loc
end

return {
  MoveBackToCamp = moveBackToCamp,
  SetCamp = setCamp
}