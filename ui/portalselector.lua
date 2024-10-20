local imgui = require('ImGui')
local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local port_spells = require "data/spells_ports"
local worldZones = require('data/zones')
local combobox = require('ui/combobox')

---@return Zone[]
local function getZones()
  local class_port_spells = port_spells.WIZ
  if not class_port_spells then
    broadcast.InfoAll("<%s> does not have portal spells configurated", mq.TLO.Me.Class.Name())
    return {}
  end

  ---@type Zone[]
  local zones = {}
  for _,continentZones in pairs(worldZones) do
    for shortname, name in pairs(continentZones) do
      if class_port_spells[shortname] then
        table.insert(zones, {name = name, shortname = shortname})
      end
    end
  end
  table.sort(zones, function(a,b) return a.name < b.name end)

  return zones
end


---@type Zone | nil
local selectedZone = nil

local function resetState()
  selectedZone = nil --[[@as Zone]]
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
    imgui.Text("Select a zone to teleport to:")

    selectedZone = combobox.RenderWithLabel("Zone", selectedZone, getZones(), convertZone)

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