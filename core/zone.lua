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

---@param zoneShortName string
---@param settingsPetType MagePetTypes|nil
---@return MagePetTypes|nil
local function petType(zoneShortName, settingsPetType)
  if(zoneShortName == "airplane") then
    if mq.TLO.Me.Class.ShortName() == "MAG" then
      if settingsPetType ~= "Air" and settingsPetType ~= "Epic" then
        return "Air"
      end
    end
  end

  return settingsPetType;
end

local function currentZoneIsNoLevitate()
  local currentZone = mq.TLO.Zone.ShortName()
  return isNoLevitate(currentZone)
end

local function currentZoneIsIndoors()
  local currentZone = mq.TLO.Zone.ShortName()
  return isIndoors(currentZone)
end

---@param settingsPetType MagePetTypes|nil
---@return MagePetTypes|nil
local function currentPetType(settingsPetType)
  local currentZone = mq.TLO.Zone.ShortName()
  return petType(currentZone, settingsPetType)
end

return {
  Current = {
    IsNoLevitate = currentZoneIsNoLevitate,
    IsIndoors = currentZoneIsIndoors,
    PetType = currentPetType
  },
  IsNoLevitate = isNoLevitate,
  IsIndoors = isIndoors,
  PetType = petType
}