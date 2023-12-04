local mq = require 'mq'
local imgui = require 'ImGui'
local icons = require 'mq/Icons'
local logger = require("knightlinc/Write")


logger.prefix = string.format("\at%s\ax", "[GITS-BAR]")
logger.postfix = function () return string.format(" %s", os.date("%X")) end

local debugUtils = require 'utils/debug'
local plugins = require 'utils/plugins'
local luapaths = require 'utils/lua-paths'
local filetutils = require 'utils/file'
local bci = require('broadcast/broadcastinterface')()

local zoneselector = require 'ui/zoneselector'
local portalselector = require 'ui/portalselector'

local runningDir = luapaths.RunningDir:new()

-- local classes
---@class ActionButton
---@field public active boolean
---@field public icon string
---@field public activeIcon? string
---@field public tooltip string
---@field public isDisabled fun(state:ActionButtons):boolean
---@field public activate fun(state:ActionButtons)
---@field public deactivate? fun(state:ActionButtons)


---@class ActionButtons
---@field public bots ActionButton
---@field public advFollow ActionButton
---@field public navFollow ActionButton
---@field public loot ActionButton
---@field public group ActionButton
---@field public pets ActionButton
---@field public petWeapons ActionButton
---@field public magicNuke ActionButton
---@field public fireNuke ActionButton
---@field public coldNuke ActionButton
---@field public bard ActionButton
---@field public toggleCrowdControl ActionButton
---@field public pacify ActionButton
---@field public quit ActionButton
---@field public door ActionButton
---@field public instance ActionButton
---@field public removeBuffs ActionButton
---@field public fooddrink ActionButton
---@field public killthis ActionButton
---@field public easyfind ActionButton
---@field public portal ActionButton

-- GUI Control variables
local openGUI = true
local terminate = false
local buttonSize = ImVec2(30, 30)
local windowFlags = bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoDocking, ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav)


local followZone = nil
local travelToZone = nil
local doInvites = false

local function create(h, s, v)
  local r, g, b = imgui.ColorConvertHSVtoRGB(h / 7.0, s, v)
  return ImVec4(r, g, b, 1)
end

local blueButton = {
  default = create(4, 0.6, 0.6),
  hovered = create(4, 0.7, 0.7),
  active = create(4, 0.8, 0.8),
}

local darkBlueButton = {
  default = create(4.8, 0.6, 0.6),
  hovered = create(4.8, 0.7, 0.7),
  active = create(4.8, 0.8, 0.8),
}

local greenButton = {
  default = create(2, 0.6, 0.6),
  hovered = create(2, 0.7, 0.7),
  active = create(2, 0.8, 0.8),
}

local redButton = {
  default = create(0, 0.6, 0.6),
  hovered = create(0, 0.7, 0.7),
  active = create(0, 0.8, 0.8),
}

local orangeButton = {
  default = create(0.55, 0.6, 0.6),
  hovered = create(0.55, 0.7, 0.7),
  active = create(0.55, 0.8, 0.8),
}

local yellowButton = {
  default = create(1, 0.6, 0.6),
  hovered = create(1, 0.7, 0.7),
  active = create(1, 0.8, 0.8),
}

local fuchsiaButton = {
  default = create(6.4, 0.6, 0.6),
  hovered = create(6.4, 0.7, 0.7),
  active = create(6.4, 0.8, 0.8),
}

local function startBots(state)
  logger.Info("Start up bots.")
  local command = string.format('/lua run %s', runningDir:GetRelativeToMQLuaPath("/bot"))
  bci.ExecuteAllCommand(command)
  state.bots.active = true
  logger.Info("Bots initialized.")
end

local function stopBots(state)
  logger.Info("stop bots.")
  local command = string.format('/lua stop %s', runningDir:GetRelativeToMQLuaPath("/bot"))
  bci.ExecuteAllCommand(command)
  state.bots.active = false
  state.toggleCrowdControl.active = false
  logger.Info("Bots stopped.")
end

---@type ActionButton
local bots = {
  active = false,
  icon = icons.MD_PLAY_ARROW, -- MD_ANDRIOD
  activeIcon = icons.MD_STOP,
  tooltip = "Toogle Bots",
  isDisabled = function (state) return false end,
  activate = function(state) startBots(state) end,
  deactivate = function(state) stopBots(state) end
}

local advFollowZone = nil
---@type ActionButton
local advFollow = {
  active = false,
  icon = icons.MD_DIRECTIONS_RUN,
  tooltip = "Toggle AdvPath Follow 'Me'",
  isDisabled = function (state) return not state.bots.active or not plugins.IsLoaded("MQ2AdvPath") end,
  activate = function(state)
    state.advFollow.active = true
    state.navFollow.active = false
    bci.ExecuteZoneCommand(string.format('/stalk %i', mq.TLO.Me.ID()))
    followZone = mq.TLO.Zone.ID()
  end,
  deactivate = function(state)
    state.advFollow.active = false
    advFollowZone = nil
    bci.ExecuteZoneCommand("/stalk")
  end
}

---@type ActionButton
local navFollow = {
  active = false,
  icon = icons.MD_MY_LOCATION, -- MD_DIRECTIONS_RUN
  tooltip = "Toggle Nav to 'Me'",
  isDisabled = function (state) return not state.bots.active or not plugins.IsLoaded("MQ2Nav") end,
  activate = function(state)
    state.navFollow.active = true
    state.advFollow.active = false
    bci.ExecuteZoneCommand(string.format('/navto %i', mq.TLO.Me.ID()))
  end,
  deactivate = function(state) state.navFollow.active = false; bci.ExecuteZoneCommand('/navto') end
}

---@type ActionButton
local loot = {
  active = false,
  icon = icons.FA_DIAMOND,
  tooltip = "Do Loot",
  isDisabled = function (state) return not state.bots.active end,
  activate = function (state)
    bci.ExecuteAllCommand('/doloot')
  end
}

local groups = {
  Eredhrin = {"Hamfast", "Newt", "Bill", "Marillion", "Ithildin"},
  Renaissance = {"Inara", "Tedd", "Araushnee", "Freyja", "Milamber"},
  Soundgarden = {"Lolth", "Ronin", "Tyrion", "Sheperd", "Valsharess"},
  Genesis = {"Vierna", "Osiris", "Eilistraee", "Regis", "Aredhel"},
  Mizzfit = {"Komodo", "Izzy", "Lulz", "Tiamat", "Nozdormu"},
}

---@type ActionButton
local group = {
  active = false,
  icon = icons.MD_GROUP,
  tooltip = "Create Groups",
  isDisabled = function (state) return false end,
  activate = function (state)
    doInvites = true
  end
}

---@type ActionButton
local pets = {
  active = false,
  icon = icons.MD_PETS,
  tooltip = "Summon Pets",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state) bci.ExecuteAllCommand('/summonpet') end,
}

---@type ActionButton
local magicNuke = {
  active = false,
  icon = icons.FA_MAGIC,
  tooltip = "Set 'Magic' nukes",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state) bci.ExecuteAllCommand('/activespellset Magic') end,
}

---@type ActionButton
local fireNuke = {
  active = false,
  icon = icons.FA_FIRE,
  tooltip = "Set 'Fire' nukes",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state) bci.ExecuteAllCommand('/activespellset Fire') end,
}

---@type ActionButton
local coldNuke = {
  active = false,
  icon = icons.FA_SNOWFLAKE_O,
  tooltip = "Set 'Cold' nukes",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state) bci.ExecuteAllCommand('/activespellset Cold') end,
}

---@type ActionButton
local resetNuke = {
  active = false,
  icon = icons.FA_MAGIC,
  tooltip = "Reset nukes",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state) bci.ExecuteAllCommand('/resetactivespellset') end,
}

local bards = {"Marillion", "Renaissance", "Soundgarden", "Genesis"}
---@type ActionButton
local bard = {
  active = false,
  icon = icons.MD_MUSIC_NOTE,
  tooltip = "Toggle Bard Twist",
  isDisabled = function (state) return not plugins.IsLoaded("MQ2Twist") or not plugins.IsLoaded("MQ2BardSwap") end,
  activate = function(state)
    state.bard.active = true
    bci.ExecuteCommand('/twist 1 2 3 4', bards)
    bci.ExecuteCommand('/if (!${BardSwap}) /bardswap', bards)
  end,
  deactivate = function(state)
    state.bard.active = false
    bci.ExecuteCommand('/twist stop', bards)
  end
}

---@type ActionButton
local petWeapons = {
  active = false,
  icon = icons.FA_SHIELD,
  tooltip = "Weaponize Your Pets",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state) bci.ExecuteZoneCommand('/weaponizepet') end,
}


local exportInventoryScriptExists = filetutils.Exists(mq.luaDir.."/inventory/export.lua")
---@type ActionButton
local quit = {
  active = false,
  icon = icons.FA_POWER_OFF,
  tooltip = "Camp Desktop",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteAllWithSelfCommand('/lua stop')
    bci.ExecuteAllWithSelfCommand('/twist off')
    bci.ExecuteAllWithSelfCommand('/camp desktop')
    if exportInventoryScriptExists then
      bci.ExecuteAllWithSelfCommand('/lua run inventory/export')
    end
  end,
}

---@type ActionButton
local door = {
  active = false,
  icon = icons.FA_KEY,
  tooltip = "Click Nearest Door",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteZoneCommand('/clickdoor')
  end,
}

---@type ActionButton
local pacify = {
  active = false,
  icon = icons.MD_REMOVE_RED_EYE,
  tooltip = "Pacify Target",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteCommand('/pacify '..mq.TLO.Target.ID(), {"Ithildin"})
  end,
}

---@type ActionButton
local toggleCrowdControl = {
  active = false,
  icon = icons.MD_SNOOZE,
  tooltip = "Toggle Crowd Control",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state)
    bci.ExecuteZoneCommand('/crowdcontrol single_mez')
    state.toggleCrowdControl.active = true
  end,
  deactivate = function(state)
    bci.ExecuteZoneCommand('/crowdcontrol')
    state.toggleCrowdControl.active = false
  end,
}

---@type ActionButton
local instance = {
  active = false,
  icon = icons. MD_EXIT_TO_APP, -- FA_CUBES
  tooltip = "Enter Instance",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteAllWithSelfCommand('/enterinstance')
  end,
}

---@type ActionButton
local removeBuffs = {
  active = false,
  icon = icons.MD_AV_TIMER, --FA_EXCHANGE,
  tooltip = "Remove Low Duration Buffs",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteAllWithSelfCommand("/cleanbuffs 120")
  end,
}

local summonFoodScriptExists = filetutils.Exists(mq.luaDir.."/mini-apps/turkey.lua")
---@type ActionButton
local fooddrink = {
  active = false,
  icon = icons.MD_RESTAURANT,
  tooltip = "Summon Food/Drink",
  isDisabled = function (state) return not summonFoodScriptExists end,
  activate = function(state)
    bci.ExecuteAllWithSelfCommand("/lua run mini-apps/turkey")
  end,
}

---@type ActionButton
local killthis = {
  active = false,
  icon = icons.MD_GPS_FIXED,
  tooltip = "Kill Current Target",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state)
  end,
}

---@type ActionButton
local clearconsole = {
  active = false,
  icon = icons.MD_FORMAT_CLEAR,
  tooltip = "Clear Console",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteAllCommand("/mqconsole clear")
    mq.cmd("/mqconsole clear")
  end,
}

local selectTravelTo = false
---@type ActionButton
local easyfind = {
  active = false,
  icon = icons.MD_DIRECTIONS_CAR,
  tooltip = "Travel Too",
  isDisabled = function (state) return false end,
  activate = function(state)
    selectTravelTo = true
  end,
  deactivate = function(state)
    bci.ExecuteAllWithSelfCommand("/travelto stop")
    state.easyfind.active = false
    travelToZone = nil
  end,
}

---@type ActionButton
local portal = {
  active = false,
  icon = icons.FA_SPACE_SHUTTLE,
  tooltip = "Portal Too",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state)
    state.portal.active = true
  end,
  deactivate = function(state)
    state.portal.active = false
  end,
}

---@type ActionButton
local reload_settings = {
  active = false,
  icon = icons.FA_RECYCLE,
  tooltip = "Reload settings",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state)
    bci.ExecuteAllWithSelfCommand("/reloadsettings")
  end
}

---@type ActionButtons
local uiState = {
  bots = bots,
  advFollow = advFollow,
  navFollow = navFollow,
  loot = loot,
  group = group,
  pets = pets,
  petWeapons = petWeapons,
  magicNuke = magicNuke,
  fireNuke = fireNuke,
  coldNuke = coldNuke,
  resetNuke = resetNuke,
  bard = bard,
  toggleCrowdControl = toggleCrowdControl,
  pacify = pacify,
  quit = quit,
  door = door,
  instance = instance,
  removeBuffs = removeBuffs,
  fooddrink = fooddrink,
  killthis = killthis,
  clearconsole = clearconsole,
  easyfind = easyfind,
  portal = portal,
  reload_settings = reload_settings
}

---@param zoneShortName Zone
local function travelToo(zoneShortName)
  if zoneShortName then
    if not mq.TLO.Zone(zoneShortName.shortname).ID() then
      logger.Error("Zone shortname does not exist <%s>", zoneShortName.shortname)
    else
      uiState.easyfind.active = true
      bci.ExecuteAllWithSelfCommand(string.format("/travelto %s", zoneShortName.shortname))
      travelToZone = zoneShortName
    end
  end

  selectTravelTo = false
end

---@param zoneShortName Zone
local function portToo(zoneShortName)
  if zoneShortName then
    if not mq.TLO.Zone(zoneShortName.shortname).ID() then
      logger.Error("Zone shortname does not exist <%s>", zoneShortName.shortname)
    else
      bci.ExecuteAllCommand(string.format("/port %s", zoneShortName.shortname))
    end
  end

  uiState.portal.active = false
end

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
local function createStateButton(state)
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
---@param buttonColor any
local function createButton(state, buttonColor)
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

local function actionbarUI()
  openGUI = imgui.Begin('Actions', openGUI, windowFlags)

  createStateButton(uiState.bots)
  imgui.SameLine()
  createStateButton(uiState.bard)
  imgui.SameLine()
  createStateButton(uiState.toggleCrowdControl)
  imgui.SameLine()
  createStateButton(uiState.advFollow)
  imgui.SameLine()
  createButton(uiState.navFollow, blueButton)
  imgui.SameLine()
  createStateButton(uiState.easyfind)
  imgui.SameLine()
  createStateButton(uiState.portal)
  imgui.SameLine()
  createButton(uiState.loot, blueButton)
  imgui.SameLine()
  createButton(uiState.group, blueButton)
  imgui.SameLine()
  createButton(uiState.pets, blueButton)
  imgui.SameLine()
  createButton(uiState.petWeapons, blueButton)

  -- next button line
  createButton(uiState.magicNuke, fuchsiaButton)
  imgui.SameLine()
  createButton(uiState.fireNuke, orangeButton)
  imgui.SameLine()
  createButton(uiState.coldNuke, darkBlueButton)
  imgui.SameLine()
  createButton(uiState.resetNuke, darkBlueButton)
  imgui.SameLine()
  createButton(uiState.pacify, yellowButton)
  imgui.SameLine()
  createButton(uiState.door, blueButton)
  imgui.SameLine()
  createButton(uiState.instance, blueButton)
  imgui.SameLine()
  createButton(uiState.fooddrink, blueButton)
  imgui.SameLine()
  createButton(uiState.removeBuffs, blueButton)
  imgui.SameLine()
  createButton(uiState.killthis, blueButton)
  imgui.SameLine()
  createButton(uiState.clearconsole, orangeButton)
  imgui.SameLine()
  createButton(uiState.reload_settings, orangeButton)
  imgui.SameLine()
  createButton(uiState.quit, redButton)

  imgui.End()

  if selectTravelTo then
    zoneselector("Travel too", travelToo)
  end

  if uiState.portal.active then
    portalselector("Port too", portToo)
  end

  if not openGUI then
      terminate = true
  end
end

mq.imgui.init('ActionBar', actionbarUI)

local function triggerInvites()
  for leader, members in pairs(groups) do
    for _, member in ipairs(members) do
      if mq.TLO.Me.Name() == leader then
        mq.cmdf("/invite %s", member)
      else
        bci.ExecuteCommand(string.format('/invite %s', member), {leader})
      end
    end
  end
  mq.delay(2000)
  for leader, members in pairs(groups) do
    for _, member in ipairs(members) do
      bci.ExecuteCommand('/invite', {member})
    end
  end
  doInvites = false
end

while not terminate do
  if doInvites then
    triggerInvites()
  end

  if followZone and followZone ~= mq.TLO.Zone.ID() then
    uiState.advFollow.active = false
    followZone = nil
  end

  if travelToZone and travelToZone.shortname == mq.TLO.Zone.ShortName() then
    uiState.easyfind.active = false
    travelToZone = nil
  end

  mq.delay(500)
end