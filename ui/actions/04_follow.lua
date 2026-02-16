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

local popup_name = 'follow_selector'
local function openPopup()
  if not imgui.IsPopupOpen(popup_name) then
    imgui.OpenPopup(popup_name)
  end
end

---@type ActionButton
local follow = {
  active = false,
  icon = icons.MD_DIRECTIONS_RUN,
  tooltip = "Follow 'Me'",
  isDisabled = function () return not app_state.IsActive() or (not plugins.IsLoaded('mq2nav') and not plugins.IsLoaded('mqactorfollow') and not plugins.IsLoaded('mq2advpath')) or follow_state:IsActive() end,
  activate = openPopup,
  deactivate = function() end
}

local activeButton, color = follow, buttons.BlueButton

---@type ActionButton
local actorFollow = {
  active = true,
  icon = icons.MD_DIRECTIONS_RUN,
  tooltip = "Actor Follow 'Me'",
  isDisabled = function () return false end,
  activate = function()
    activeButton, color = follow, buttons.BlueButton
    bci.ExecuteZoneWithSelfCommand("/stalk")
  end,
  deactivate = function() end
}

---@type ActionButton
local advFollow = {
  active = true,
  icon = icons.MD_DIRECTIONS_RUN,
  tooltip = "Adv Follow 'Me'",
  isDisabled = function () return false end,
  activate = function()
    activeButton, color = follow, buttons.BlueButton
    bci.ExecuteZoneWithSelfCommand("/stalkadv")
  end,
  deactivate = function() end
}

---@type ActionButton
local navFollow = {
  active = true,
  icon = icons.MD_DIRECTIONS_RUN, -- MD_DIRECTIONS_RUN
  tooltip = "Nav Follow 'Me'",
  isDisabled = function () return false end,
  activate = function()
    activeButton, color = follow, buttons.BlueButton
    bci.ExecuteZoneWithSelfCommand('/navto')
  end,
  deactivate = function() end
}

---@type ActionButton
local stickFollow = {
  active = true,
  icon = icons.MD_DIRECTIONS_RUN, -- MD_DIRECTIONS_RUN
  tooltip = "Stick Follow 'Me'",
  isDisabled = function () return false end,
  activate = function()
    activeButton, color = follow, buttons.BlueButton
    bci.ExecuteZoneWithSelfCommand('/gitstick')
  end,
  deactivate = function() end
}

local function renderFollowSelectorPopup()
  if imgui.BeginPopup(popup_name) then
    imgui.SeparatorText("Follow mode");
    if plugins.IsLoaded('mqactorfollow') and imgui.Selectable("Actor") then
      activeButton, color = actorFollow, buttons.GreenButton
      bci.ExecuteZoneWithSelfCommand(string.format('/stalk %i', mq.TLO.Me.ID()))
    end
    if plugins.IsLoaded('mq2advpath') and imgui.Selectable("AdvFollow") then
      activeButton, color = advFollow, buttons.GreenButton
      bci.ExecuteZoneWithSelfCommand(string.format('/stalkadv %i', mq.TLO.Me.ID()))
    end
    if plugins.IsLoaded('mq2nav') and imgui.Selectable("Nav") then
      activeButton, color = navFollow, buttons.GreenButton
      bci.ExecuteZoneWithSelfCommand(string.format('/navto %i', mq.TLO.Me.ID()))
    end
    if plugins.IsLoaded('mq2moveutils') and imgui.Selectable("Stick") then
      activeButton, color = stickFollow, buttons.GreenButton
      bci.ExecuteZoneWithSelfCommand(string.format('/gitstick %i', mq.TLO.Me.ID()))
    end
    imgui.EndPopup()
  end
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    if follow_state:IsActive() then
      buttons.CreateButton(activeButton, color, buttonSize)
    else
      buttons.CreateButton(follow, buttons.BlueButton, buttonSize)
    end
    renderFollowSelectorPopup()
  end
}