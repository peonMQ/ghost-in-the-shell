local mq = require('mq')
local mqutil = require('utils/mqhelpers')
local logger = require('knightlinc/Write')
local assist = require('core/assist')
local movement = require('core/movement')
local app_state = require('app_state')

--- Calculates the distance between two points (x1, y1) and (x2, y2).
--- @param x1 number The x-coordinate of the first point.
--- @param y1 number The y-coordinate of the first point.
--- @param x2 number The x-coordinate of the second point.
--- @param y2 number The y-coordinate of the second point.
--- @return number The distance between the two points.
function GetDistance(x1, y1, x2, y2)
  --return mq.TLO.Math.Distance(string.format("%d,%d:%d,%d", y1 or 0, x1 or 0, y2 or 0, x2 or 0))()
  return math.sqrt(GetDistanceSquared(x1, y1, x2, y2))
end

--- Calculates the squared distance between two points (x1, y1) and (x2, y2).
--- This is useful for distance comparisons without the computational cost of a square root.
--- @param x1 number The x-coordinate of the first point.
--- @param y1 number The y-coordinate of the first point.
--- @param x2 number The x-coordinate of the second point.
--- @param y2 number The y-coordinate of the second point.
--- @return number The squared distance between the two points.
function GetDistanceSquared(x1, y1, x2, y2)
  return ((x2 or 0) - (x1 or 0)) ^ 2 + ((y2 or 0) - (y1 or 0)) ^ 2
end

local MIN_CAMP_DISTANCE = 10

local function onTick()
  if assist.IsOrchestrator() then
    return
  end

  local camp = app_state.CampLoc
  if not camp then
    return
  end

  local me = mq.TLO.Me
  local campDistance = GetDistance(me.X(), me.Y(), camp.x, camp.y)
  if campDistance <= MIN_CAMP_DISTANCE then
    logger.Debug("Not far enough from camp, staying put.")
    return
  end

  if campDistance > 200 then
    logger.Debug("Camp out of range <%s>, removing camp spot.", campDistance)
    app_state.CampLoc = nil
    return
  end

  if mqutil.NPCInRange(100) then
    logger.Debug("NPCs in camp range, staying put.")
    return
  end

  logger.Debug("Moving to camp at %s:%s:%s", camp.x, camp.y, camp.z)
  movement.MoveToLoc(camp.x, camp.y, camp.z, MIN_CAMP_DISTANCE)
end

return {
  Process = onTick
}