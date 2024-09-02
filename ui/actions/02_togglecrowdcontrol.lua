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

---@type ActionButton
local toggleCrowdControl = {
  active = false,
  icon = icons.MD_SNOOZE,
  tooltip = "Toggle Crowd Control",
  isDisabled = function () return not app_state.IsActive() end,
  activate = function () end,
  deactivate = function () end,
}

toggleCrowdControl.activate = function ()
  bci.ExecuteZoneCommand('/crowdcontrol single_mez')
  toggleCrowdControl.active = true
end

toggleCrowdControl.deactivate = function ()
  bci.ExecuteZoneCommand('/crowdcontrol')
  toggleCrowdControl.active = false
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateStateButton(toggleCrowdControl, buttonSize)
  end,
}