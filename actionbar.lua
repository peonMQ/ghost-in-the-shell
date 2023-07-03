--- @type ImGui
require 'ImGui'

--- @type Mq
local mq = require 'mq'

--- @type Icons
local icons = require 'mq/icons'
local logger = require 'utils/logging'
local debugUtils = require 'utils/debug'
local plugins = require('utils/plugins')
local luapaths = require('utils/lua-paths')
local filetutils = require('utils/file')
local broadCastInterfaceFactory = require('broadcast/broadcastinterface')

local zoneselector = require('ui/zoneselector')

---@type RunningDir
local runningDir = luapaths.RunningDir:new()
runningDir:AppendToPackagePath()

local bci = broadCastInterfaceFactory()
if not bci then
  logger.Fatal("No networking interface found, please start eqbc or dannet")
  return
end

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

-- GUI Control variables
local openGUI = true
local terminate = false
local buttonSize = ImVec2(30, 30)
local windowFlags = bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoDocking, ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav)


local followZone = nil
local travelToZone = nil
local looter = nil
local doInvites = false

local function create(h, s, v)
  local r, g, b = ImGui.ColorConvertHSVtoRGB(h / 7.0, s, v)
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
  local command = string.format('/lua run %s', runningDir:GetRelativeToMQLuaPath("bot"))
  bci.ExecuteAllCommand(command)
  state.bots.active = true
  logger.Info("Bots initialized.")
end

local function stopBots(state)
  logger.Info("stop bots.")
  local command = string.format('/lua stop %s', runningDir:GetRelativeToMQLuaPath("bot"))
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
  icon = icons.MD_DIRECTIONS_CAR,
  tooltip = "Toggle AdvPath Follow 'Me'",
  isDisabled = function (state) return not state.bots.active or not plugins.IsLoaded("MQ2AdvPath") end,
  activate = function(state)
    state.advFollow.active = true
    state.navFollow.active = false
    bci.ExecuteAllCommand(string.format('/stalk %i', mq.TLO.Me.ID()))
    followZone = mq.TLO.Zone.ID()
  end,
  deactivate = function(state)
    state.advFollow.active = false
    advFollowZone = nil
    bci.ExecuteAllCommand("/stalk")
  end
}

---@type ActionButton
local navFollow = {
  active = false,
  icon = icons.FA_PLANE, -- MD_DIRECTIONS_RUN
  tooltip = "Toggle Nav to 'Me'",
  isDisabled = function (state) return not state.bots.active or not plugins.IsLoaded("MQ2Nav") end,
  activate = function(state) 
    state.navFollow.active = true
    state.advFollow.active = false
    bci.ExecuteAllCommand(string.format('/navto %i', mq.TLO.Me.ID()))
  end,
  deactivate = function(state) state.navFollow.active = false; bci.ExecuteAllCommand('/navto') end
}

---@type ActionButton
local loot = {
  active = false,
  icon = icons.FA_DIAMOND,
  tooltip = "Do Loot",
  isDisabled = function (state) return not state.bots.active end,
  activate = function (state)
    if not looter then
      logger.Warn("No looter defined. use /setlooter 'looter' to define one.")
    else
      bci.ExecuteCommand('/doloot', {looter})
    end
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
  activate = function(state) bci.ExecuteAllCommand('/setlineup Magic') end,
}

---@type ActionButton
local fireNuke = {
  active = false,
  icon = icons.FA_FIRE,
  tooltip = "Set 'Fire' nukes",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state) bci.ExecuteAllCommand('/setlineup Fire') end,
}

---@type ActionButton
local coldNuke = {
  active = false,
  icon = icons.FA_SNOWFLAKE_O,
  tooltip = "Set 'Cold' nukes",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state) bci.ExecuteAllCommand('/setlineup Cold') end,
}

---@type ActionButton
local bards = {"Marillion", "Renaissance", "Soundgarden", "Genesis"}
local bard = {
  active = false,
  icon = icons.MD_MUSIC_NOTE,
  tooltip = "Toggle Bard Twist",
  isDisabled = function (state) return not plugins.IsLoaded("MQ2Twist") or not plugins.IsLoaded("MQ2BardSwap") end,
  activate = function(state)
    state.bard.active = true
    for _, name in pairs(bards) do
      bci.ExecuteCommand('/twist 1 2 3 4', {name})
      bci.ExecuteCommand('/if (!${BardSwap}) /bardswap', {name})
    end
  end,
  deactivate = function(state)
    state.bard.active = false
    bci.ExecuteAllCommand('/twist stop')
  end
}

---@type ActionButton
local petWeapons = {
  active = false,
  icon = icons.FA_SHIELD,
  tooltip = "Weaponize Your Pets",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state) bci.ExecuteAllCommand('/weaponizepet') end,
}

---@type ActionButton
local quit = {
  active = false,
  icon = icons.FA_POWER_OFF,
  tooltip = "Camp Desktop",
  isDisabled = function (state) return false end,
  activate = function(state) 
    bci.ExecuteAllCommand('/lua stop', true)
    bci.ExecuteAllCommand('/twist off', true)
    bci.ExecuteAllCommand('/camp desktop', true)
  end,
}

---@type ActionButton
local door = {
  active = false,
  icon = icons.FA_KEY,
  tooltip = "Click Nearest Door",
  isDisabled = function (state) return false end,
  activate = function(state) 
    bci.ExecuteAllCommand('/doortarget')
    bci.ExecuteAllCommand('/click left door')
  end,
}

---@type ActionButton
local pacify = {
  active = false,
  icon = icons.MD_REMOVE_RED_EYE,
  tooltip = "Pacify Target",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteCommand('/multiline ; /target id '..mq.TLO.Target.ID()..'; /cast  "Pacify" ', {"Ithildin"})
  end,
}

---@type ActionButton
local toggleCrowdControl = {
  active = false,
  icon = icons.MD_SNOOZE,
  tooltip = "Toggle Crowd Control",
  isDisabled = function (state) return not state.bots.active end,
  activate = function(state)
    bci.ExecuteAllCommand('/docc on')
    state.toggleCrowdControl.active = true
  end,
  deactivate = function(state)
    bci.ExecuteAllCommand('/docc off')
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
    bci.ExecuteAllCommand('/target id '..mq.TLO.Target.ID())
    bci.ExecuteAllCommand('/say ready', true)
  end,
}

local removeBuffsScriptExists = filetutils.Exists(mq.luaDir.."/mini-apps/removebuffs.lua")
---@type ActionButton
local removeBuffs = {
  active = false,
  icon = icons.MD_AV_TIMER, --FA_EXCHANGE,
  tooltip = "Remove Low Duration Buffs",
  isDisabled = function (state) return not removeBuffsScriptExists end,
  activate = function(state)
    bci.ExecuteAllCommand("/lua run mini-apps/removebuffs 120", true)
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
    bci.ExecuteAllCommand("/lua run mini-apps/turkey", true)
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
  icon = icons.MD_DIRECTIONS_RUN,
  tooltip = "Travel Too",
  isDisabled = function (state) return false end,
  activate = function(state)
    selectTravelTo = true
  end,
  deactivate = function(state)
    bci.ExecuteAllCommand("/travelto stop", true)
    state.easyfind.active = false
    travelToZone = nil
  end,
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
}

---@param zoneShortName Zone
local function travelToo(zoneShortName)
  if zoneShortName then
    if not mq.TLO.Zone(zoneShortName.shortname).ID() then
      logger.Error("Zone shortname does not exist <%s>", zoneShortName.shortname)
    else
      uiState.easyfind.active = true
      bci.ExecuteAllCommand(string.format("/travelto %s", zoneShortName.shortname), true)
      travelToZone = zoneShortName
    end
  end

  selectTravelTo = false
end

local function DrawTooltip(text)
  if ImGui.IsItemHovered() and text and string.len(text) > 0 then
      ImGui.BeginTooltip()
      ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35.0)
      ImGui.Text(text)
      ImGui.PopTextWrapPos()
      ImGui.EndTooltip()
  end
end

---@param state ActionButton
local function createStateButton(state)
  if not state then
    return
  end

  if not state.active then
    ImGui.PushStyleColor(ImGuiCol.Button, blueButton.default)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, greenButton.hovered)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, greenButton.active)
    local isDisabled = state.isDisabled(uiState)
    ImGui.BeginDisabled(isDisabled)
    ImGui.Button(state.icon, buttonSize)
    ImGui.EndDisabled()
  else
    ImGui.PushStyleColor(ImGuiCol.Button, greenButton.default)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, redButton.hovered)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, redButton.hovered)
    local isDisabled = state.isDisabled(uiState)
    ImGui.BeginDisabled(isDisabled)
    if not state.activeIcon then
      ImGui.Button(state.icon, buttonSize)
    else
      ImGui.Button(state.activeIcon, buttonSize)
    end
    ImGui.EndDisabled()
  end

  DrawTooltip(state.tooltip)

  if ImGui.IsItemClicked(0) then
    if not state.active then
      state.activate(uiState)
    else
      state.deactivate(uiState)
    end
  end

  ImGui.PopStyleColor(3)
end

---@param state ActionButton
---@param buttonColor any
local function createButton(state, buttonColor)
  ImGui.PushStyleColor(ImGuiCol.Button, buttonColor.default)
  ImGui.PushStyleColor(ImGuiCol.ButtonHovered, buttonColor.hovered)
  ImGui.PushStyleColor(ImGuiCol.ButtonActive, buttonColor.active)

  local isDisabled = state.isDisabled(uiState)
  ImGui.BeginDisabled(isDisabled)
  ImGui.Button(state.icon, buttonSize)
  ImGui.EndDisabled()
  DrawTooltip(state.tooltip)
  if not isDisabled and ImGui.IsItemClicked(0) then
    state.activate(uiState)
  end

  ImGui.PopStyleColor(3)
end

local function actionbarUI()
  openGUI = ImGui.Begin('Actions', openGUI, windowFlags)

  createStateButton(uiState.bots)
  ImGui.SameLine()
  createStateButton(uiState.bard)
  ImGui.SameLine()
  createStateButton(uiState.toggleCrowdControl)
  ImGui.SameLine()
  createStateButton(uiState.advFollow)
  ImGui.SameLine()
  createButton(uiState.navFollow, blueButton)
  ImGui.SameLine()
  createStateButton(uiState.easyfind)
  ImGui.SameLine()
  createButton(uiState.loot, blueButton)
  ImGui.SameLine()
  createButton(uiState.group, blueButton)
  ImGui.SameLine()
  createButton(uiState.pets, blueButton)
  ImGui.SameLine()
  createButton(uiState.petWeapons, blueButton)

  -- next button line
  createButton(uiState.magicNuke, fuchsiaButton)
  ImGui.SameLine()
  createButton(uiState.fireNuke, orangeButton)
  ImGui.SameLine()
  createButton(uiState.coldNuke, darkBlueButton)
  ImGui.SameLine()
  createButton(uiState.pacify, yellowButton)
  ImGui.SameLine()
  createButton(uiState.door, blueButton)
  ImGui.SameLine()
  createButton(uiState.instance, blueButton)
  ImGui.SameLine()
  createButton(uiState.fooddrink, blueButton)
  ImGui.SameLine()
  createButton(uiState.removeBuffs, blueButton)
  ImGui.SameLine()
  createButton(uiState.killthis, blueButton)
  ImGui.SameLine()
  createButton(uiState.clearconsole, orangeButton)
  ImGui.SameLine()
  createButton(uiState.quit, redButton)

  ImGui.End()

  if selectTravelTo then
    zoneselector("Travel too", travelToo)
  end

  if not openGUI then
      terminate = true
  end
end

mq.imgui.init('ActionBar', actionbarUI)

local function setLooter(arg)
  if not arg or string.len(arg) < 3 then
    logger.Warn("<looter> param is not set.")
    return
  end

  looter = arg
  logger.Info("Looter set to <%s>", looter)
end

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

local function createAliases()
  mq.unbind('/setlooter')
  mq.bind("/setlooter", setLooter)
end

createAliases()

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