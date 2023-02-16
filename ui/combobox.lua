--- @type ImGui
local imgui = require 'ImGui'
local debugUtils = require 'utils/debug'

local function renderHelpMarker(desc)
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
        imgui.Text(desc)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

---@generic T 
---@param label string
---@param selectedValue T
---@param options T[]
---@param displayText fun(value: T): string
---@param helpText string?
---@return T
local function renderComboBox(label, selectedValue, options, displayText, helpText)
    imgui.Text(label)
    imgui.SameLine()
    local selectedText = displayText(selectedValue)
    if imgui.BeginCombo("##"..label, selectedText, 0) then
        for _,j in ipairs(options) do
            local valueText = displayText(j)
            if imgui.Selectable(valueText, valueText == selectedText) then
                selectedText = displayText(j)
                selectedValue = j
            end
        end
        imgui.EndCombo()
    end
    if helpText then
        imgui.SameLine()
        renderHelpMarker(helpText)
    end
    return selectedValue
end

return renderComboBox