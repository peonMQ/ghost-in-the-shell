-- Author: Aquietone

local mq = require('mq')
local imgui = require('ImGui')
local app_state = require('app_state')
local assist_state = require('application/assist_state')
local follow_state = require('application/follow_state')
local medley_state = require('application/medley/state')
local commandQueue  = require('application/command_queue')

local WHITE = ImVec4(1, 1, 1, 1)
local GREEN = ImVec4(0, 1, 0, 1)
local YELLOW = ImVec4(1, 1, 0, 1)
local RED = ImVec4(1, 0, 0, 1)
local LIGHT_BLUE = ImVec4(.6, .8, 1, 1)
local ORANGE = ImVec4(1, .65, 0, 1)
local GREY = ImVec4(.8, .8, .8, 1)
local GOLD = ImVec4(.7, .5, 0, 1)

local TABLE_FLAGS = bit32.bor(ImGuiTableFlags.RowBg,ImGuiTableFlags.BordersOuter,ImGuiTableFlags.BordersV,ImGuiTableFlags.Sortable,ImGuiTableFlags.Hideable, ImGuiTableFlags.Reorderable)

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

---@param filter string|false
local function drawTableTree(filter)
  local filters = nil
  if filter then
      filters = splitSet(filter:lower(), '|')
  end
  imgui.Text("App State")
  if imgui.BeginTable('##AppStatesTable', 2, TABLE_FLAGS) then
      imgui.TableSetupColumn('Key', ImGuiTableColumnFlags.None, 2, 1)
      imgui.TableSetupColumn('Value', ImGuiTableColumnFlags.None, 2, 2)
      imgui.TableHeadersRow()
      drawNestedTableTree(app_state, filters)
      imgui.EndTable()
  end
  imgui.NewLine()
  imgui.Text("Assist State")
  if imgui.BeginTable('##AssistStatesTable', 2, TABLE_FLAGS) then
      imgui.TableSetupColumn('Key', ImGuiTableColumnFlags.None, 2, 1)
      imgui.TableSetupColumn('Value', ImGuiTableColumnFlags.None, 2, 2)
      imgui.TableHeadersRow()
      drawNestedTableTree(assist_state, filters)
      imgui.EndTable()
  end
  imgui.NewLine()
  imgui.Text("Follow State")
  if imgui.BeginTable('##FollowStatesTable', 2, TABLE_FLAGS) then
      imgui.TableSetupColumn('Key', ImGuiTableColumnFlags.None, 2, 1)
      imgui.TableSetupColumn('Value', ImGuiTableColumnFlags.None, 2, 2)
      imgui.TableHeadersRow()
      drawNestedTableTree(follow_state, filters)
      imgui.EndTable()
  end
  imgui.NewLine()
  imgui.Text("Command queue")
  if imgui.BeginTable('##CommandQueueTable', 2, TABLE_FLAGS) then
      imgui.TableSetupColumn('Key', ImGuiTableColumnFlags.None, 2, 1)
      imgui.TableSetupColumn('Value', ImGuiTableColumnFlags.None, 2, 2)
      imgui.TableHeadersRow()
      drawNestedTableTree(commandQueue.Size(), filters)
      imgui.EndTable()
  end
  if mq.TLO.Me.Class.ShortName() == "BRD" then
    imgui.NewLine()
    imgui.Text("Medley State")
    if imgui.BeginTable('##MedleyStatesTable', 2, TABLE_FLAGS) then
        imgui.TableSetupColumn('Key', ImGuiTableColumnFlags.None, 2, 1)
        imgui.TableSetupColumn('Value', ImGuiTableColumnFlags.None, 2, 2)
        imgui.TableHeadersRow()
        drawNestedTableTree(medley_state, filters)
        imgui.EndTable()
    end
  end
end

local function render()
  debugFilter = imgui.InputTextWithHint('##debugfilterstates', 'Filter...', debugFilter)
  drawTableTree(debugFilter ~= '' and debugFilter)
end

return render