local mq = require('mq')
local imgui = require('ImGui')
local icons = require('mq/Icons')
local logger = require('knightlinc/Write')
local debugUtils = require('utils/debug')
local plugins = require('utils/plugins')
local filetutils = require('utils/file')
local bci = require('broadcast/broadcastinterface')('REMOTE')
local app_state = require('app_state')
local follow_state = require('application/follow_state')
local buttons = require('ui/buttons')
local portalselector = require('ui/portalselector')

---@type ActionButton
local portal = {
  active = false,
  icon = icons.FA_SPACE_SHUTTLE,
  tooltip = "Portal Too",
  isDisabled = function () return not app_state.IsActive() end,
  activate = function() end,
  deactivate = function() end,
}

portal.activate = function ()
  portal.active = true
end

portal.deactivate = function ()
  portal.active = false
end

---@param zoneShortName Zone
local function portToo(zoneShortName)
  if zoneShortName then
    if not mq.TLO.Zone(zoneShortName.shortname).ID() then
      logger.Error("Zone shortname does not exist <%s>", zoneShortName.shortname)
    else
      bci.ExecuteZoneCommand(string.format("/port %s", zoneShortName.shortname))
    end
  end

  portal.active = false
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateStateButton(portal, buttonSize)

    if portal.active then
      portalselector("Port too", portToo)
    end
  end
}