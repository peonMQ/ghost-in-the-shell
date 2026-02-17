local mq = require('mq')
local logger = require('knightlinc/Write')
local plugins = require('utils/plugins')
local timer = require('core/timer')

local function arrivedAtDestination(xLoc, yLoc, distanceDelta)
  local distance = mq.TLO.Math.Distance(string.format('%d,%d', (yLoc), (xLoc)))()
  logger.Debug('%d,%d <%d>', (xLoc), (yLoc), distance)
  return distance <= distanceDelta
end

local function moveToMe()
  local me = mq.TLO.Me
  local xLoc = me.X()
  local yLoc = me.Y()
  local distanceDelta = 10
  if arrivedAtDestination(xLoc, yLoc, distanceDelta) then
    return
  end

  mq.cmdf("/bca //nav id %d", me.ID())
end

local function moveToLoc(xLoc, yLoc, zLoc, maxTime, arrivalDist)
  if not xLoc or not yLoc then
    logger.Debug("Cannot move to location <x:%d> <y:%d>", xLoc, yLoc)
    return false
  end

  if not mq.TLO.Navigation.PathExists(string.format("loc %d %d %d", yLoc, xLoc, zLoc)) then
    logger.Debug("Cannot navgiate to location <x:%d> <y:%d>, no path exists.", xLoc, yLoc, zLoc)
    return false
  end

  if mq.TLO.Navigation.Active() then
    mq.cmd("/nav stop")
  end

  if mq.TLO.MoveUtils.Command() ~= "NONE" then
    mq.cmd("/stick off")
    mq.cmd("/moveto off")
  end

  local distanceDelta = arrivalDist or 10
  local maxTryTime = maxTime or 3

  logger.Debug("Distance to loc <x:%d> <y:%d> => <%d>", xLoc, yLoc, mq.TLO.Math.Distance(string.format('%d,%d', (yLoc), (xLoc)))())
  if arrivedAtDestination(xLoc, yLoc, distanceDelta) then
    return true
  end

  if mq.TLO.Me.Casting.ID() and mq.TLO.Me.Class.ShortName() ~= "BRD" then
    mq.cmd("/stopcast")
  end

  local timeOut = timer:new(maxTryTime)

  local navCmd = string.format("/nav loc %d %d %d", yLoc, xLoc, zLoc)
  while not arrivedAtDestination(xLoc, yLoc, distanceDelta) and timeOut:IsRunning() do
    if not mq.TLO.Navigation.Active() then
      mq.cmd(navCmd)
    end

    mq.delay(maxTryTime * 1000 / 5, function() return arrivedAtDestination(xLoc, yLoc, distanceDelta) end)
  end

  mq.cmd("/nav stop")
  return arrivedAtDestination(xLoc, yLoc, distanceDelta)
end

local function isFollowing()
  if plugins.IsLoaded("mq2nav") and mq.TLO.Navigation.Active() then
    return true
  end

  if plugins.IsLoaded("mqactorfollow") and mq.TLO.ActorFollow.IsFollowing() then
    return true
  end

  if plugins.IsLoaded("mq2advpath") and mq.TLO.AdvPath.Following() then
    return true
  end

  if plugins.IsLoaded("mq2moveutils") and mq.TLO.Stick.Active() then
    local stickSpawn = mq.getFilteredSpawns(function(spawn) return spawn.ID() == mq.TLO.Stick.StickTarget() and  spawn.Type() =="PC" end)
    if next(stickSpawn) then
      return true
    end
  end

  return false
end

local movement = {
  IsFollowing = isFollowing,
  MoveToLoc = moveToLoc,
  MoveTome = moveToMe
}

return movement