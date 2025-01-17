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

local popup_name = 'medley_selector'

local function openPopup()
  if not imgui.IsPopupOpen(popup_name) then
    imgui.OpenPopup(popup_name)
  end
end

---@type ActionButton
local generalMedley = {
  active = false,
  icon = icons.FA_MUSIC,
  tooltip = "Now playing: General",
  isDisabled = function () return not app_state.IsActive() end,
  activate = openPopup,
}

local activeMedley, color = generalMedley, buttons.BlueButton

local function renderNukeSelectorPopup()
  if imgui.BeginPopup(popup_name) then
    imgui.SeparatorText("Medley");
    if imgui.Selectable("General") then
      generalMedley.tooltip = "Now playing: General"
      activeMedley, color = generalMedley, buttons.BlueButton
      bci.ExecuteZoneWithSelfCommand('/activemedley general')
    end
    if imgui.Selectable("Fire dragon") then
      generalMedley.tooltip = "Now playing: Fire dragon"
      activeMedley, color = generalMedley, buttons.OrangeButton
      bci.ExecuteZoneWithSelfCommand('/activemedley firedragon')
    end
    if imgui.Selectable("Cold dragon") then
      generalMedley.tooltip = "Now playing: Cold dragon"
      activeMedley, color = generalMedley, buttons.DarkBlueButton
      bci.ExecuteZoneWithSelfCommand('/activemedley colddragon')
    end
    if imgui.Selectable("Posion dragon") then
      generalMedley.tooltip = "Now playing: Poison resistance"
      activeMedley, color = generalMedley, buttons.OrangeButton
      bci.ExecuteZoneWithSelfCommand('/activemedley poisondragon')
    end
    if imgui.Selectable("Disease dragon") then
      generalMedley.tooltip = "Now playing: Disease resistance"
      activeMedley, color = generalMedley, buttons.OrangeButton
      bci.ExecuteZoneWithSelfCommand('/activemedley diseaseedragon')
    end
    if imgui.Selectable("Levitate") then
      generalMedley.tooltip = "Now playing: Levitate"
      activeMedley, color = generalMedley, buttons.FuchsiaButton
      bci.ExecuteZoneWithSelfCommand('/activemedley levitate')
    end
    if imgui.Selectable("Fire resistance") then
      generalMedley.tooltip = "Now playing: Fire resistance"
      activeMedley, color = generalMedley, buttons.OrangeButton
      bci.ExecuteZoneWithSelfCommand('/activemedley fire')
    end
    if imgui.Selectable("Cold resistance") then
      generalMedley.tooltip = "Now playing: Cold resistance"
      activeMedley, color = generalMedley, buttons.DarkBlueButton
      bci.ExecuteZoneWithSelfCommand('/activemedley cold')
    end
    if imgui.Selectable("Travel") then
      generalMedley.tooltip = "Now playing: Travel"
      activeMedley, color = generalMedley, buttons.BlueButton
      bci.ExecuteZoneWithSelfCommand('/activemedley travel')
    end
    if imgui.Selectable("DOT") then
      generalMedley.tooltip = "Now playing: DOT"
      activeMedley, color = generalMedley, buttons.RedButton
      bci.ExecuteZoneWithSelfCommand('/activemedley dot')
    end
    imgui.EndPopup()
  end
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(activeMedley, color, buttonSize)
    renderNukeSelectorPopup()
  end,
}