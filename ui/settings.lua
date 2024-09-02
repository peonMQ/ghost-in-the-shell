-- Author: Aquietone

local mq = require('mq')
local imgui = require('ImGui')
local settings = require('settings/settings')

local WHITE = ImVec4(1, 1, 1, 1)
local GREEN = ImVec4(0, 1, 0, 1)
local YELLOW = ImVec4(1, 1, 0, 1)
local RED = ImVec4(1, 0, 0, 1)
local LIGHT_BLUE = ImVec4(.6, .8, 1, 1)
local ORANGE = ImVec4(1, .65, 0, 1)
local GREY = ImVec4(.8, .8, .8, 1)
local GOLD = ImVec4(.7, .5, 0, 1)

local TABLE_FLAGS = bit32.bor(ImGuiTableFlags.ScrollY,ImGuiTableFlags.RowBg,ImGuiTableFlags.BordersOuter,ImGuiTableFlags.BordersV,ImGuiTableFlags.SizingStretchSame,ImGuiTableFlags.Sortable,
                                ImGuiTableFlags.Hideable, ImGuiTableFlags.Resizable, ImGuiTableFlags.Reorderable)

local debugFilter = ''

local function splitSet(input, sep)
  if sep == nil then
      sep = "|"
  end
  local t={}
  for str in string.gmatch(input, "([^"..sep.."]+)") do
      t[str] = true
  end
  return t
end

local function matchFilters(k, filters)
  for filter,_ in pairs(filters) do
      if k:lower():find(filter) then return true end
  end
end

---@param table table
---@param filters table|nil
local function drawNestedTableTree(table, filters)
  for k, v in pairs(table) do
    if not filters or matchFilters(k, filters) then
      if type(v) ~= 'table' and type(v) ~= 'function' then
        imgui.TableNextRow()
        imgui.TableNextColumn()
        imgui.TextColored(WHITE, '%s', tostring(k))
        imgui.TableNextColumn()
        imgui.TextColored(LIGHT_BLUE, '%s', v)
        imgui.TableNextColumn()
      end
    end
  end
  for k, v in pairs(table) do
    if not filters or matchFilters(k, filters) then
      if type(v) == 'table' then
        imgui.TableNextRow()
        imgui.TableNextColumn()
        local open = imgui.TreeNodeEx(tostring(k), ImGuiTreeNodeFlags.SpanFullWidth)
        if open then
          drawNestedTableTree(v)
          imgui.TreePop()
        end
      end
    end
  end
end

---@param table table
---@param filter string|false
local function drawTableTree(table, filter)
  local filters = nil
  if filter then
      filters = splitSet(filter:lower(), '|')
  end
  if imgui.BeginTable('StateTable', 2, TABLE_FLAGS, -1, -1) then
      imgui.TableSetupScrollFreeze(0, 1)
      imgui.TableSetupColumn('Key', ImGuiTableColumnFlags.None, 2, 1)
      imgui.TableSetupColumn('Value', ImGuiTableColumnFlags.None, 2, 2)
      imgui.TableHeadersRow()
      drawNestedTableTree(table, filters)
      imgui.EndTable()
  end
end

local function render()
  debugFilter = imgui.InputTextWithHint('##debugfilter', 'Filter...', debugFilter)
  drawTableTree(settings, debugFilter ~= '' and debugFilter)
end

return render