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
local assist_state = require('application/assist_state')
local buttons = require('ui/buttons')

local popup_name = 'nuke_selector'

local function openPopup()
  if not imgui.IsPopupOpen(popup_name) then
    imgui.OpenPopup(popup_name)
  end
end

---@type ActionButton
local mainNuke = {
  active = false,
  icon = icons.FA_MAGIC,
  tooltip = "'Main' nukes",
  isDisabled = function () return not app_state.IsActive() end,
  activate = openPopup,
}

---@type ActionButton
local magicNuke = {
  active = false,
  icon = icons.FA_MAGIC,
  tooltip = "'Magic' nukes",
  isDisabled = function () return not app_state.IsActive() end,
  activate = openPopup,
}

---@type ActionButton
local fireNuke = {
  active = false,
  icon = icons.FA_FIRE,
  tooltip = "'Fire' nukes",
  isDisabled = function () return not app_state.IsActive() end,
  activate = openPopup,
}

---@type ActionButton
local coldNuke = {
  active = false,
  icon = icons.FA_SNOWFLAKE_O,
  tooltip = "'Cold' nukes",
  isDisabled = function () return not app_state.IsActive() end,
  activate = openPopup,
}

local activeNuke, color = mainNuke, buttons.BlueButton

local function renderNukeSelectorPopup()
  if imgui.BeginPopup(popup_name) then
    imgui.SeparatorText("Wizard/Mage Nuke");
    if imgui.Selectable("Cold") then
      activeNuke, color = coldNuke, buttons.DarkBlueButton
      bci.ExecuteZoneCommand('/activespellset Cold')
    end
    if imgui.Selectable("Fire") then
      activeNuke, color = fireNuke, buttons.OrangeButton
      bci.ExecuteZoneCommand('/activespellset Fire')
    end
    if imgui.Selectable("Magic") then
      activeNuke, color = magicNuke, buttons.FuchsiaButton
      bci.ExecuteZoneCommand('/activespellset Magic')
    end
    if imgui.Selectable("Reset") then
      activeNuke, color = mainNuke, buttons.BlueButton
      bci.ExecuteZoneCommand('/resetactivespellset')
    end
    imgui.EndPopup()
  end
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(activeNuke, color, buttonSize)
    renderNukeSelectorPopup()
  end,
}