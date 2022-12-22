--- @type Mq
local mq = require('mq')

--- @type ImGui
require('ImGui')

-- Import our zones file
local zones = require('lib.zones')

-- Import special Ladon zone file
local ladon_zones = require('lib.ladonzones')

-- Libaray used to read/write ini files
local lip = require('lib.LIP')

-- Define some icons
local icons = {
   -- FA_PLAY = '\xef\x81\x8b',
   -- FA_PAUSE = '\xef\x81\x8c',
   -- FA_STOP = '\xef\x81\x8d',
   -- FA_HEART = '\xef\x80\x84'
}

local is_open = true
local is_drawn = true
local is_group = false
local was_group_selected = false
local window_title = 'Magellan'
local application_name = 'Magellan'
local search_term = ''
local dest = ''
local dest_name = ''
local window_height = nil
local collapsed_window_height = 110

local waypoint_name = ''
local waypoints = {}

local ladon_selected = false
local current_sort_specs = nil
local ColumnID_ID = 0
local ColumnID_Name = 1
local ColumnID_Shortname = 2

local function CompareWithSortSpecs(a, b)
   for n = 1, current_sort_specs.SpecsCount, 1 do
      -- Here we identify columns using the ColumnUserID value that we ourselves passed to TableSetupColumn()
      -- We could also choose to identify columns based on their index (sort_spec.ColumnIndex), which is simpler!
      local sort_spec = current_sort_specs:Specs(n)
      local delta = 0

      if sort_spec.ColumnUserID == ColumnID_ID then
         delta = a[1] - b[1]
      elseif sort_spec.ColumnUserID == ColumnID_Name then
         if a[2] < b[2] then
            delta = -1
         elseif b[2] < a[2] then
            delta = 1
         else
            delta = 0
         end
      elseif sort_spec.ColumnUserID == ColumnID_Shortname then
         if a[3] < b[3] then
            delta = -1
         elseif b[3] < a[3] then
            delta = 1
         else
            delta = 0
         end
      end

      if delta ~= 0 then
         if sort_spec.SortDirection == ImGuiSortDirection.Ascending then return delta < 0 end
         return delta > 0
      end
   end
end

local function file_exists(path)
   local f = io.open(path, 'r')
   if f ~= nil then
      io.close(f)
      return true
   else
      return false
   end
end

local function reload_waypoints()
   local config_dir = mq.configDir:gsub('\\', '/') .. '/'
   print('\am[Magellan]\ax Reloading MQ2Nav Waypoints')
   local waypoints_file = 'mq2nav.ini'
   local waypoints_path = config_dir .. waypoints_file
   waypoints = lip.load(waypoints_path)
end

local function load_settings()
   local config_dir = mq.configDir:gsub('\\', '/') .. '/'

   print('\am[Magellan]\ax Loading MQ2Nav Waypoints')
   local waypoints_file = 'mq2nav.ini'
   local waypoints_path = config_dir .. waypoints_file
   waypoints = lip.load(waypoints_path)

   print('\am[Magellan]\ax Loading Group Settings')
   local settings_file = string.format('%s.ini', application_name)
   Settings_path = config_dir .. settings_file

   if file_exists(Settings_path) then
      Settings = lip.load(Settings_path)
      is_group = Settings.Magellan.group
      if not Settings.Favorites then
         Settings.Favorites = { 'Plane of Knowledge' }
         lip.save(Settings_path, Settings)
      end
   else
      Settings = {
         Magellan = {
            group = false
         },
         Favorites = {}
      }
      lip.save(Settings_path, Settings)
   end
end

local function save_settings()
   print('\am[Magellan]\ax Saving Settings')
   lip.save(Settings_path, Settings)
end

-- Flattens and sorts the hierachtical list into a simple list of tables holding zone information
local function flatten(t, favs)
   local r = {}
   for ex, ex_zones in pairs(t) do
      for sname, lname in pairs(ex_zones) do
         local favorite = false
         if lname then
            local long_name = lname[1] or lname
            for _, fav in ipairs(favs) do
               if lname == fav then
                  favorite = true
               end
            end
            table.insert(r, {
               expansion = ex,
               shortname = sname,
               name = long_name,
               favorite = favorite
            })
         end
      end
   end
   table.sort(r, function(a, b) return a.name < b.name end)
   return r
end

local function structured(t)
   local r = {}
   for k, v in pairs(t) do r[k] = v end
   table.sort(r, function(a, b)
      if a.expansion < b.expansion then return true end
      if a.expansion > b.expansion then return false end
      return a.name < b.name
   end)
   return r
end

-- Go ahead and create/load settings file
load_settings()

--- Create a nice alphabetical listing of zones
local ordered_zones = flatten(zones, Settings.Favorites)

--- Order the Hierachtical listing of zones by expansion/name
local structured_zones = structured(ordered_zones)

--- Correctly makes the call to /travelto based on action desired and group settings
---@param s string destination/action (e.g. zone or stop/pause)
---@param b boolean in_group?
local function travel(s, b)
   if b and mq.TLO.Group.Leader.ID() then
      if s == 'stop' then
         mq.cmdf('/dgae /travelto %s', s)
      else
         mq.cmdf('/travelto group %s', s)
      end
   else
      mq.cmdf('/travelto %s', s)
   end
end

local function createSelectable(index, zone)
   ImGui.Selectable('\t' .. zone.name)
   if ImGui.IsItemClicked(ImGuiMouseButton.Left) then
      dest = zone.shortname
      dest_name = zone.name
      travel(dest, is_group)
   end
   if ImGui.IsItemClicked(ImGuiMouseButton.Right) then
      zone.favorite = not zone.favorite
      structured_zones[index] = zone
      if zone.favorite then
         table.insert(Settings.Favorites, zone.name)
      else
         for index, value in ipairs(Settings.Favorites) do
            if value == zone.name then table.remove(Settings.Favorites, index) break end
         end
      end
      save_settings()
   end
   return zone
end

-- As the function name implies, this is the main function that draws our window
local function draw_main_window()
   if is_open then
      ImGui.SetWindowSize(800, 500, ImGuiCond.Once)
      if ImGui.GetWindowHeight() > collapsed_window_height then window_height = ImGui.GetWindowHeight() end

      is_open, is_drawn = ImGui.Begin(window_title, is_open)
      if is_drawn then

         if dest_name == '' then dest_name = 'None Selected' end
         ImGui.Text(string.format('Destination: %s', dest_name))

         if ImGui.Button(string.format('%s Pause', icons.FA_PAUSE)) then travel('stop', is_group) end

         ImGui.SameLine()
         if ImGui.Button(string.format('%s Continue', icons.FA_PLAY)) then travel(dest, is_group) end

         ImGui.SameLine()
         if ImGui.Button(string.format('%s Stop', icons.FA_STOP)) then
            travel('stop', is_group)
            dest, dest_name, search_term = '', '', ''
         end

         ImGui.SameLine()
         if mq.TLO.Group() then
            is_group, was_group_selected = ImGui.Checkbox('Group Travel', is_group)
            if was_group_selected then
               Settings.Magellan.group = is_group
               save_settings()
            end
         else
            ImGui.TextDisabled('Not in Group')
         end

         if ImGui.CollapsingHeader('Zone List (click to toggle)') then
            ImGui.SetWindowSize(ImGui.GetWindowWidth(), window_height or collapsed_window_height)

            search_term = ImGui.InputText('Filter', search_term)
            ImGui.Separator()

            local prev_zone = ''
            local curr_expansion = ''

            ImGui.BeginTabBar('ZoneLists', ImGuiTabBarFlags.Reorderable)

            if ImGui.BeginTabItem('Favorites') then
               ImGui.BeginChild('Favorites')
               ImGui.Text('Right-Click on a zone to select/deselect Favorite status.')
               for index, zone in ipairs(structured_zones) do
                  if ((#search_term > 2 and string.find(zone.name:lower(), search_term:lower())) and zone.favorite) or
                      #search_term < 1 and zone.favorite then

                     if zone.expansion ~= curr_expansion then
                        ImGui.TextColored(1, .89, .25, 1, zone.expansion)
                     end
                     zone = createSelectable(index, zone)
                     if zone.favorite then
                        ImGui.SameLine()
                        ImGui.Text(icons.FA_HEART)
                     end
                     curr_expansion = zone.expansion
                  end
               end
               ImGui.EndChild()
               ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem('By Expansion') then
               ImGui.BeginChild('ZonesByExpansion')
               ImGui.Text('Right-Click on a zone to select/deselect Favorite status.')
               for index, zone in ipairs(structured_zones) do
                  if (#search_term > 1 and string.find(zone.name:lower(), search_term:lower())) or #search_term < 2 then

                     if zone.expansion ~= curr_expansion then
                        ImGui.TextColored(1, .89, .25, 1, zone.expansion)
                     end
                     zone = createSelectable(index, zone)
                     if zone.favorite then
                        ImGui.SameLine()
                        ImGui.Text(icons.FA_HEART)
                     end
                     curr_expansion = zone.expansion
                  end
               end
               ImGui.EndChild()
               ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem('Waypoints') then
               ImGui.BeginChild('Waypoints')
               ImGui.Dummy(0, 5)
               ImGui.Indent(5.0)
               waypoint_name = ImGui.InputTextWithHint('##waypoint_name', 'Enter new waypoint name', waypoint_name)
               ImGui.SameLine()
               if ImGui.Button('New') then
                  if #waypoint_name > 1 then
                     mq.cmd.nav('rwp "' .. waypoint_name .. '"')
                     waypoint_name = ''
                  end
               end
               ImGui.Separator()
               ImGui.TextColored(1, .89, .25, 1, string.format('Waypoints for %s', mq.TLO.Zone.Name()))
               ImGui.Separator()
               for zone, zone_waypoints in pairs(waypoints) do
                  if string.lower(mq.TLO.Zone.ShortName()) == zone then
                     for desc, _ in pairs(zone_waypoints) do
                        if ImGui.Selectable(desc .. '##' .. desc) then
                           mq.cmd.nav('wp "' .. desc .. '"')
                        end
                     end
                  end
               end
               ImGui.Unindent()
               ImGui.EndChild()
               ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem('Ladon View') then
               ImGui.BeginChild('LadonZones')
               if ImGui.BeginTable('ladon', 3,
                  ImGuiTableFlags.Sortable + ImGuiTableFlags.Resizable + ImGuiTableFlags.Borders) then
                  ImGui.TableSetupColumn('ZoneID', (ImGuiTableColumnFlags.DefaultSort + ImGuiTableColumnFlags.WidthFixed
                     ),
                     20.0, ColumnID_ID)
                  ImGui.TableSetupColumn('Name', ImGuiTableColumnFlags.DefaultSort, 0.0, ColumnID_Name)
                  ImGui.TableSetupColumn('Shortname', ImGuiTableColumnFlags.DefaultSort, 0.0, ColumnID_Shortname)
                  ImGui.TableHeadersRow()

                  local sort_specs = ImGui.TableGetSortSpecs()
                  if sort_specs then
                     if sort_specs.SpecsDirty then
                        for n = 1, sort_specs.SpecsCount, 1 do sort_specs:Specs(n) end

                        if #ladon_zones > 1 then
                           current_sort_specs = sort_specs
                           table.sort(ladon_zones, CompareWithSortSpecs)
                           current_sort_specs = nil
                        end
                        sort_specs.SpecsDirty = false
                     end
                  end

                  for _, zone in ipairs(ladon_zones) do
                     if (#search_term > 1 and string.find(zone[2]:lower(), search_term:lower())) or #search_term < 2 then
                        ImGui.TableNextRow()
                        ImGui.TableNextColumn()
                        ImGui.Text(tostring(zone[1]))
                        ImGui.TableNextColumn()
                        if ImGui.Selectable(zone[2], ladon_selected, ImGuiSelectableFlags.SpanAllColumns) then
                           travel(zone[3], is_group)
                        end
                        ImGui.TableNextColumn()
                        ImGui.Text(zone[3])
                     end
                  end

                  ImGui.EndTable()
               end
               ImGui.EndChild()
               ImGui.EndTabItem()
            end

            ImGui.EndTabBar()
         else
            ImGui.SetWindowSize(ImGui.GetWindowWidth(), collapsed_window_height)
         end
      end
   else
      return
   end
   ImGui.End()
end

local function color_wrap()
   ImGui.PushStyleColor(ImGuiCol.WindowBg, .23, .035, .42, 1)
   ImGui.PushStyleColor(ImGuiCol.TitleBgActive, .14, .00, .27, 1)
   ImGui.PushStyleColor(ImGuiCol.FrameBg, .87, .66, 1, 1)
   ImGui.PushStyleColor(ImGuiCol.Button, .61, .30, .86, .75)
   ImGui.PushStyleColor(ImGuiCol.ButtonHovered, .61, .30, .86, 1)
   ImGui.PushStyleColor(ImGuiCol.ChildBg, .48, .17, .74, 1)
   ImGui.PushStyleColor(ImGuiCol.Header, .23, .035, .42, .45)
   ImGui.PushStyleColor(ImGuiCol.HeaderHovered, .25, .065, .52, .45)
   ImGui.PushStyleColor(ImGuiCol.HeaderActive, .23, .035, .42, .45)
   draw_main_window()
   ImGui.PopStyleColor(9)
end

-- Inialize the event for Nav recording waypoints
mq.event('MQNav Waypoint Recorded', '#*#Recorded waypoint:#*#', reload_waypoints)

-- Inialize our application
mq.imgui.init(application_name, color_wrap)

-- Continue to check for the state of the application
while is_open do
   mq.doevents()
   mq.delay(1000)
end
