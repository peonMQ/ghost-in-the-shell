--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')
local plugin = require('utils/plugins')
local settings = require('settings/settings')

local next = next

---@return string?
local function getMainTank()
  if plugin.IsLoaded("mq2netbots") == false then
    logger.Debug("mq2netbots is not loaded")
    return nil
  end

  if next(settings.assist.tanks) == nil then
    logger.Debug("No MainTanks defined.")
    return nil
 end

 for _, maintank in ipairs(settings.assist.tanks) do
  local netbot = mq.TLO.NetBots(maintank)
  if netbot.ID() and netbot.InZone() then
    return maintank
  end
 end

 return nil
end

local function amIOfftank()
  local mainTank = getMainTank()
  if not mainTank then
    return false
  end

  if mainTank == mq.TLO.Me.Name() then
    return false
  end

  for i=1, #settings.assist.tanks do
    if settings.assist.tanks[i] == mainTank and settings.assist.tanks[i+1] == mq.TLO.Me.Name() then
      local netbot = mq.TLO.NetBots(settings.assist.tanks[i])
      if netbot.ID() and netbot.InZone() then
        return true
      else
        return false
      end
    end
  end

  return false
end

---@return string?
local function getMainAssist()
  if plugin.IsLoaded("mq2netbots") == false then
    logger.Debug("mq2netbots is not loaded")
    return nil
  end

  if next(settings.assist.main_assist) == nil then
    logger.Debug("No MainAssists defined.")
    return nil
 end

 for _, mainAssist in ipairs(settings.assist.main_assist) do
  local netbot = mq.TLO.NetBots(mainAssist)
  if netbot.ID() and netbot.InZone() then
    return mainAssist
  end
 end

 logger.Debug("Mainassist not found")
 return nil
end

---@param targetSpawn MQSpawn
---@return boolean
local function isValidKillTarget(targetSpawn)
  if not targetSpawn() then
    return false
  end

  local isNPC = targetSpawn.Type() == "NPC"
  local isPet = targetSpawn.Type() == "Pet"
  local hasLineOfSight = targetSpawn.LineOfSight()
  local isPetOwnerPC = true
  if isPet then
    isPetOwnerPC = targetSpawn.Master.Type() == "PC"
  end

  if not isNPC
     or (isPet and isPetOwnerPC)
     or (settings.assist.require_los and not hasLineOfSight)
     or targetSpawn() and targetSpawn.Distance() > settings.assist.range then
      logger.Debug("Invalid target: %s::%s::%s::%s::%s::%s", targetSpawn.CleanName(), isNPC, isPet, isPetOwnerPC, hasLineOfSight, targetSpawn.Distance())
      return false
  end

  return true
end

---@param engage_at integer
---@return spawn?
local function getMainAssistTarget(engage_at)
  local mainAssist = getMainAssist()
  if not mainAssist then
    return nil
  end

  local mainassist =  mq.TLO.NetBots(mainAssist)
  local targetId =  mainassist.TargetID()
  local targetSpawn = mq.TLO.Spawn(targetId) --[[@as spawn]]
  local targetHP = mainassist.TargetHP() -- cannot use targetSpawn.PctHP() because it doesnt update unless its targeted

  if not isValidKillTarget(targetSpawn)
     or (targetHP > 0 and targetHP > engage_at) then
      logger.Debug("Mainassist target not found: <%s/%s>", targetHP, engage_at)
      return nil
  end

  logger.Debug("Mainassist target found: <%s/%s>", targetHP, engage_at)
  return targetSpawn
end

-- Am I the foreground instance?
---@return boolean
local function is_orchestrator()
  return mq.TLO.EverQuest.Foreground() -- or mq.TLO.FrameLimiter.Status() == "Foreground"
end


local commonUtil = {
  GetMainAssist = getMainAssist,
  GetMainTank = getMainTank,
  AmIOfftank = amIOfftank,
  GetMainAssistTarget = getMainAssistTarget,
  IsValidKillTarget = isValidKillTarget,
  IsOrchestrator = is_orchestrator
}

return commonUtil