-- Author: Aquietone

local mq = require('mq')
local imgui = require('ImGui')
local repository = require('application/looting/repository')

local WHITE = ImVec4(1, 1, 1, 1)
local GREEN = ImVec4(0, 1, 0, 1)
local YELLOW = ImVec4(1, 1, 0, 1)
local RED = ImVec4(1, 0, 0, 1)
local LIGHT_BLUE = ImVec4(.6, .8, 1, 1)
local ORANGE = ImVec4(1, .65, 0, 1)
local GREY = ImVec4(.8, .8, .8, 1)
local GOLD = ImVec4(.7, .5, 0, 1)

local TABLE_FLAGS = bit32.bor(ImGuiTableFlags.ScrollY,ImGuiTableFlags.RowBg,ImGuiTableFlags.BordersOuter,ImGuiTableFlags.BordersV,ImGuiTableFlags.SizingStretchSame,
                                ImGuiTableFlags.Hideable, ImGuiTableFlags.Resizable)

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

---@param table LootItem[]
---@param filters table|nil
local function drawLootTable(table, filters)
  for index, lootItem in ipairs(table) do
    if not filters or matchFilters(lootItem.Name, filters) then
      local pressed = false
      imgui.TableNextRow()
      imgui.TableNextColumn()
      imgui.TextColored(WHITE, '%s', lootItem.Name.." ("..lootItem.Id..")")
      imgui.TableNextColumn()
      lootItem.DoDestroy, pressed = imgui.Checkbox("##destroy"..index, lootItem.DoDestroy) --- @diagnostic disable-line: param-type-mismatch
      if pressed then
        repository:upsert(lootItem)
      end
      imgui.TableNextColumn()
      lootItem.DoSell = imgui.Checkbox("##sell"..index, lootItem.DoSell) --- @diagnostic disable-line: param-type-mismatch
      if pressed then
        repository:upsert(lootItem)
      end
      imgui.TableNextColumn()
      if imgui.Button("Remove##remove"..index) then
        repository:remove(index)
      end
    end
  end
end

---@param table LootItem[]
---@param filter string|false
local function drawTableTree(table, filter)
  local filters = nil
  if filter then
      filters = splitSet(filter:lower(), '|')
  end
  imgui.SetWindowFontScale(0.9)
  if imgui.BeginTable('LootTable', 4, TABLE_FLAGS, -1, -1) then
      imgui.TableSetupScrollFreeze(0, 1)
      imgui.TableSetupColumn('Name', ImGuiTableColumnFlags.WidthStretch, 2, 1)
      imgui.TableSetupColumn('Destroy', ImGuiTableColumnFlags.None, 1, 2)
      imgui.TableSetupColumn('Sell', ImGuiTableColumnFlags.None, 1, 3)
      imgui.TableSetupColumn('Remove', ImGuiTableColumnFlags.None, 1, 4)
      imgui.TableHeadersRow()
      drawLootTable(table, filters)
      imgui.EndTable()
  end
  ImGui.SetWindowFontScale(1)
end

local function render()
  debugFilter = imgui.InputTextWithHint('##lootdebugfilter', 'Filter...', debugFilter)
  imgui.BeginDisabled(mq.TLO.Cursor() == nil)
  imgui.SameLine()
  if imgui.Button("Add delete") then
    mq.cmd("/setdestroyitem")
  end
  imgui.SameLine()
  if imgui.Button("Add sell") then
    mq.cmd("/setsellitem")
  end
  imgui.EndDisabled()
  drawTableTree(repository.items, debugFilter ~= '' and debugFilter)

end

return render