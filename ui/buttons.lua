local imgui = require 'ImGui'
local logger = require("knightlinc/Write")

-- local classes
---@class ActionButton
---@field public active boolean
---@field public icon string
---@field public activeIcon? string
---@field public tooltip string
---@field public isDisabled fun(state:ActionButtons):boolean
---@field public activate fun(state:ActionButtons)
---@field public deactivate? fun(state:ActionButtons)


---@param h number
---@param s number
---@param v number
---@return ImVec4
local function create(h, s, v)
  local r, g, b = imgui.ColorConvertHSVtoRGB(h / 7.0, s, v)
  return ImVec4(r, g, b, 1)
end

---@class ButtonColors
---@field default ImVec4
---@field hovered ImVec4
---@field active ImVec4

---@type ButtonColors
local blueButton = {
  default = create(4, 0.6, 0.6),
  hovered = create(4, 0.7, 0.7),
  active = create(4, 0.8, 0.8),
}

---@type ButtonColors
local darkBlueButton = {
  default = create(4.8, 0.6, 0.6),
  hovered = create(4.8, 0.7, 0.7),
  active = create(4.8, 0.8, 0.8),
}

---@type ButtonColors
local greenButton = {
  default = create(2, 0.6, 0.6),
  hovered = create(2, 0.7, 0.7),
  active = create(2, 0.8, 0.8),
}

---@type ButtonColors
local redButton = {
  default = create(0, 0.6, 0.6),
  hovered = create(0, 0.7, 0.7),
  active = create(0, 0.8, 0.8),
}

---@type ButtonColors
local orangeButton = {
  default = create(0.55, 0.6, 0.6),
  hovered = create(0.55, 0.7, 0.7),
  active = create(0.55, 0.8, 0.8),
}

---@type ButtonColors
local yellowButton = {
  default = create(1, 0.6, 0.6),
  hovered = create(1, 0.7, 0.7),
  active = create(1, 0.8, 0.8),
}

---@type ButtonColors
local fuchsiaButton = {
  default = create(6.4, 0.6, 0.6),
  hovered = create(6.4, 0.7, 0.7),
  active = create(6.4, 0.8, 0.8),
}

local function DrawTooltip(text)
  if imgui.IsItemHovered() and text and string.len(text) > 0 then
      imgui.BeginTooltip()
      imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
      imgui.Text(text)
      imgui.PopTextWrapPos()
      imgui.EndTooltip()
  end
end

---@param state ActionButton
---@param buttonSize ImVec2
---@param uiState ActionButtons
local function createStateButton(state, buttonSize, uiState)
  if not state then
    return
  end

  if not state.active then
    imgui.PushStyleColor(ImGuiCol.Button, blueButton.default)
    imgui.PushStyleColor(ImGuiCol.ButtonHovered, greenButton.hovered)
    imgui.PushStyleColor(ImGuiCol.ButtonActive, greenButton.active)
    local isDisabled = state.isDisabled(uiState)
    imgui.BeginDisabled(isDisabled)
    imgui.Button(state.icon, buttonSize)
    imgui.EndDisabled()
  else
    imgui.PushStyleColor(ImGuiCol.Button, greenButton.default)
    imgui.PushStyleColor(ImGuiCol.ButtonHovered, redButton.hovered)
    imgui.PushStyleColor(ImGuiCol.ButtonActive, redButton.hovered)
    local isDisabled = state.isDisabled(uiState)
    imgui.BeginDisabled(isDisabled)
    if not state.activeIcon then
      imgui.Button(state.icon, buttonSize)
    else
      imgui.Button(state.activeIcon, buttonSize)
    end
    imgui.EndDisabled()
  end

  DrawTooltip(state.tooltip)

  if imgui.IsItemClicked(0) then
    if not state.active then
      state.activate(uiState)
    else
      state.deactivate(uiState)
    end
  end

  imgui.PopStyleColor(3)
end

---@param state ActionButton
---@param buttonColor ButtonColors
---@param buttonSize ImVec2
---@param uiState ActionButtons
local function createButton(state, buttonColor, buttonSize, uiState)
  imgui.PushStyleColor(ImGuiCol.Button, buttonColor.default)
  imgui.PushStyleColor(ImGuiCol.ButtonHovered, buttonColor.hovered)
  imgui.PushStyleColor(ImGuiCol.ButtonActive, buttonColor.active)

  local isDisabled = state.isDisabled(uiState)
  imgui.BeginDisabled(isDisabled)
  imgui.Button(state.icon, buttonSize)
  imgui.EndDisabled()
  DrawTooltip(state.tooltip)
  if not isDisabled and imgui.IsItemClicked(0) then
    state.activate(uiState)
  end

  imgui.PopStyleColor(3)
end

return {
  BlueButton = blueButton,
  DarkBlueButton = darkBlueButton,
  FuchsiaButton = fuchsiaButton,
  GreenButton = greenButton,
  OrangeButton = orangeButton,
  RedButton = redButton,
  YellowButton = yellowButton,
  CreateStateButton = createStateButton,
  CreateButton = createButton
}