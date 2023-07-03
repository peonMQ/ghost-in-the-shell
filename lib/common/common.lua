--- @type Mq
local mq = require 'mq'
local logger = require 'utils/logging'
local plugin = require 'utils/plugins'
local config = require 'lib/common/config'

local next = next 

---@return string?
local function getMainTank()
  if plugin.IsLoaded("mq2netbots") == false then
    logger.Debug("mq2netbots is not loaded")
    return nil
  end

  if next(config.MainTanks) == nil then
    logger.Debug("No MainTanks defined.")
    return nil
 end
 
 for key, maintank in pairs(config.MainTanks) do
  local netbot = mq.TLO.NetBots(maintank)
  if netbot.ID() ~= "NULL" and netbot.InZone() ~= "NULL" then
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
 
  for i=1, #config.MainTanks do
    if config.MainTanks[i] == mainTank and config.MainTanks[i+1] == mq.TLO.Me.Name() then
      local netbot = mq.TLO.NetBots(config.MainTanks[i])
      if netbot.ID() ~= "NULL" and netbot.InZone() ~= "NULL" then
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

  if next(config.MainAssists) == nil then
    logger.Debug("No MainAssists defined.")
    return nil
 end
 
 for key, mainAssist in pairs(config.MainAssists) do
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