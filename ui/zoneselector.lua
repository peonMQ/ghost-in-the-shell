--- @type ImGui
local imgui = require 'ImGui'

local renderCombobox = require('ui/combobox')
local worldZones = require('ui/zones')

---@type Continent[]
local continents = {}
for continent,continentZones in pairs(worldZones) do
  local cz = {}
  for shortname, name in pairs(continentZones) do
    table.insert(cz, {name = name, shortname = shortname})
  end
  table.sort(cz, function(a,b) return a.name < b.name end)
  table.insert(continents, {name = continent, zones = cz})
end

table.sort(continents, function(a,b)
  if a.name == "Div" then
    return false
  elseif b.name == "Div" then
    return true
  else
    return a.name < b.name
  end
end)


---@type Continent | nil
local selectedContinent = nil
---@type Zone | nil
local selectedZone = nil

local function resetState()
  selectedContinent = nil --[[@as Continent]]
  selectedZone = nil --[[@as Zone]]
end

local function convertContient(continent)
  if continent then
    return continent.name
  end

  return ""
end

local function convertZone(zone)
  if zone then
    return zone.name
  end

  return ""
end

---@param okText string
---@param selectedZoneAction fun(selectedZone?: Zone)
local function renderZoneSelector(okText, selectedZoneAction)
  if not imgui.IsPopupOpen("Select Zone") then
    imgui.OpenPopup("Select Zone")
  end

  if imgui.BeginPopupModal("Select Zone", nil, ImGuiWindowFlags.AlwaysAutoResize) then
    imgui.Text("Select a continent and zone to go to:")

    selectedContinent = renderCombobox("Continent", selectedContinent, continents, convertContient)
    if selectedContinent and selectedContinent.zones then
      selectedZone = renderCombobox("Zone", selectedZone, selectedContinent.zones, convertZone)
    end

    ImGui.BeginDisabled(not selectedZone)
    if imgui.Button(okText) and selectedZone then
      local zoneShortName = selectedZone
      resetState()
      imgui.CloseCurrentPopup()
      selectedZoneAction(zoneShortName);
    end
    ImGui.EndDisabled()

    imgui.SameLine()

    if imgui.Button("Cancel") then
      resetState()
      imgui.CloseCurrentPopup()
      selectedZoneAction();
    end

    imgui.EndPopup()
  end
end

return renderZoneSelector