--- @type Mq
local mq = require 'mq'
local logger = require("knightlinc/Write")
local plugin = require 'utils/plugins'
local settings = require 'settings/settings'

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
  if netbot.ID() and netbot.ID() ~= "NULL" and netbot.InZone() ~= "NULL" then
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
      if netbot.ID() and netbot.ID() ~= "NULL" and netbot.InZone() ~= "NULL" then
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
  if netbot.ID() ~= "NULL" and netbot.InZone() ~= "NULL" then
    return mainAssist
  end
 end

 return nil
end

local commonUtil = {
  GetMainAssist = getMainAssist,
  GetMainTank = getMainTank,
  AmIOfftank = amIOfftank
}

return commonUtil