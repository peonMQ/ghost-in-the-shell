local mq = require('mq')
local logger = require('knightlinc/Write')

---@param zoneShortName string
---@return boolean
local function isIndoors(zoneShortName)
  return string.find("befallen blackburrow gukbottom guktop neriaka neriakb neriakc paw permafrost qcat runnyeye soldunga soldungb soltemple akanon kaladima kaladimb kedge kurn kaesora sebilis", zoneShortName) ~= nil
end

---@param zoneShortName string
---@return boolean
local function isNoLevitate(zoneShortName)
  return zoneShortName == "airplane"
end

local function currentZoneIsNoLevitate()
  local currentZone = mq.TLO.Zone.ShortName()
  return isNoLevitate(currentZone)
end

local function currentZoneIsIndoors()
  local currentZone = mq.TLO.Zone.ShortName()
  return isIndoors(currentZone)
end

return {
  Current = {
    IsNoLevitate = currentZoneIsNoLevitate,
    IsIndoors = currentZoneIsIndoors
  },
  IsNoLevitate = isNoLevitate,
  IsIndoors = isIndoors
}