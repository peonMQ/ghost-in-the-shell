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

local active, color = follow, buttons.BlueButton

---@type ActionButton
local actorFollow = {
  active = true,
  icon = icons.MD_DIRECTIONS_RUN,
  tooltip = "Actor Follow 'Me'",
  isDisabled = function () return false end,
  activate = function()
    active, color = follow, buttons.BlueButton
    bci.ExecuteZoneCommand("/stalk")
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
    active, color = follow, buttons.BlueButton
    bci.ExecuteZoneCommand("/stalkadv")
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
    active, color = follow, buttons.BlueButton
    bci.ExecuteZoneCommand('/navto')
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
    active, color = follow, buttons.BlueButton
    bci.ExecuteZoneCommand('/gitstick')
  end,
  deactivate = function() end
}

local function renderNukeSelectorPopup()
  if imgui.BeginPopup(popup_name) then
    imgui.SeparatorText("Follow mode");
    if plugins.IsLoaded('mqactorfollow') and imgui.Selectable("Actor") then
      active, color = actorFollow, buttons.GreenButton
      bci.ExecuteZoneCommand(string.format('/stalk %i', mq.TLO.Me.ID()))
    end
    if plugins.IsLoaded('mq2advpath') and imgui.Selectable("AdvFollow") then
      active, color = advFollow, buttons.GreenButton
      bci.ExecuteZoneCommand(string.format('/stalkadv %i', mq.TLO.Me.ID()))
    end
    if plugins.IsLoaded('mq2nav') and imgui.Selectable("Nav") then
      active, color = navFollow, buttons.GreenButton
      bci.ExecuteZoneCommand(string.format('/navto %i', mq.TLO.Me.ID()))
    end
    if plugins.IsLoaded('mq2moveutils') and imgui.Selectable("Stick") then
      active, color = navFollow, buttons.GreenButton
      bci.ExecuteZoneCommand(string.format('/gitstick %i', mq.TLO.Me.ID()))
    end
    imgui.EndPopup()
  end
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(active, color, buttonSize)
    renderNukeSelectorPopup()
  end
}