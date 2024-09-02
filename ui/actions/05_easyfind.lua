local mq = require('mq')
local imgui = require('ImGui')
local icons = require('mq/Icons')
local logger = require('knightlinc/Write')
local debugUtils = require('utils/debug')
local plugins = require('utils/plugins')
local filetutils = require('utils/file')
local bci = require('broadcast/broadcastinterface')('ACTOR')
local app_state = require('app_state')
local follow_state = require('application/follow_state')
local buttons = require('ui/buttons')
local zoneselector = require('ui/zoneselector')

local travelToZone = nil
local selectTravelTo = false

---@type ActionButton
local easyfind = {
  active = false,
  icon = icons.MD_DIRECTIONS_CAR,
  tooltip = "Travel Too",
  isDisabled = function () return not app_state.IsActive() or not plugins.IsLoaded("mq2easyfind") end,
  activate = function() end,
  deactivate = function() end,
}

easyfind.activate = function ()
  selectTravelTo = true
end

easyfind.deactivate = function ()
  bci.ExecuteZoneWithSelfCommand("/travelto stop")
  easyfind.active = false
  travelToZone = nil
end

---@param zoneShortName Zone
local function travelToo(zoneShortName)
  if zoneShortName then
    if not mq.TLO.Zone(zoneShortName.shortname).ID() then
      logger.Error("Zone shortname does not exist <%s>", zoneShortName.shortname)
    else
      easyfind.active = true
      bci.ExecuteZoneWithSelfCommand(string.format("/travelto %s", zoneShortName.shortname))
      travelToZone = zoneShortName
    end
  end

  selectTravelTo = false
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateStateButton(easyfind, buttonSize)

    if selectTravelTo then
      zoneselector("Travel too", travelToo)
    end
  end,
  OnClick = function()
    if travelToZone and travelToZone.shortname == mq.TLO.Zone.ShortName() then
      easyfind.active = false
      travelToZone = nil
    end
  end
}