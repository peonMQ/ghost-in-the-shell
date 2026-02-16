local mq = require('mq')
local imgui = require('ImGui')
local icons = require('mq/Icons')
local logger = require('knightlinc/Write')
local debugUtils = require('utils/debug')
local bci = require('broadcast/broadcastinterface')('REMOTE')
local app_state = require('app_state')
local buttons = require('ui/buttons')


local popup_name = 'crowdcontrol_selector'

local function openPopup()
  if not imgui.IsPopupOpen(popup_name) then
    imgui.OpenPopup(popup_name)
  end
end

---@type ActionButton
local setCrowdControl = {
  active = false,
  icon = icons.MD_SNOOZE,
  tooltip = "Toggle Crowd Control",
  isDisabled = function () return not app_state.IsActive() end,
  activate = openPopup,
}

local activeButton, color = setCrowdControl, buttons.BlueButton

---@type ActionButton
local disableCrowdControl = {
  active = false,
  icon = icons.MD_SNOOZE,
  tooltip = "Disable Crowd Control",
  isDisabled = function () return not app_state.IsActive() end,
  activate = function ()
    bci.ExecuteZoneCommand('/crowdcontrol')
    activeButton, color = setCrowdControl, buttons.BlueButton
  end
}

local function renderActionPopup()
  if imgui.BeginPopup(popup_name) then
    imgui.SeparatorText("Crowd Control Mode");
    if imgui.Selectable("Single") then
      disableCrowdControl.tooltip = "Single"
      activeButton, color = disableCrowdControl, buttons.GreenButton
      bci.ExecuteZoneCommand('/crowdcontrol single_mez')
    end
    if imgui.Selectable("Unresistable (single)") then
      disableCrowdControl.tooltip = "Unresistable (single)"
      activeButton, color = disableCrowdControl, buttons.GreenButton
      bci.ExecuteZoneCommand('/crowdcontrol unresistable_mez')
    end
    if imgui.Selectable("Area") then
      disableCrowdControl.tooltip = "Area"
      activeButton, color = disableCrowdControl, buttons.GreenButton
      bci.ExecuteZoneCommand('/crowdcontrol ae_mez')
    end
    imgui.EndPopup()
  end
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(activeButton, color, buttonSize)
    renderActionPopup()
  end,
}