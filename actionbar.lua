--- @type ImGui
require 'ImGui'

--- @type Mq
local mq = require 'mq'
local icons = require 'mq/icons'
local logger = require 'utils/logging'
local debugUtils = require 'utils/debug'
local plugins = require('utils/plugins')
local luapaths = require('utils/lua-paths')
local broadCastInterfaceFactory = require('broadcast/broadcastinterface')


---@type RunningDir
local runningDir = luapaths.RunningDir:new()
runningDir:AppendToPackagePath()

local bci = broadCastInterfaceFactory()
if not bci then
  logger.Fatal("No networking interface found, please start eqbc or dannet")
  return
end

local looter = nil

-- GUI Control variables
local openGUI = true
local terminate = false
local buttonSize = ImVec2(30, 30)
local windowFlags = bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoDocking, ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav)

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

local function startBots()
  logger.Info("Start up bots.")
  -- local command = string.format('/lua run %s', runningDir:GetRelativeToMQLuaPath("bot"))
  -- bci.ExecuteAllCommand(command)
  bci.ExecuteAllCommand('/lua run bot')
  logger.Info("Bots initialized.")
end

local bots = {
  active = false,
  icon = icons.MD_PLAY_ARROW, -- MD_ANDRIOD
  activeIcon = icons.MD_STOP,
  tooltip = "Toogle Bots",
  activate = function(state) state.bots.active = true; startBots() end,
  deactivate = function(state) state.bots.active = false; bci.ExecuteAllCommand("/lua stop bot", true) end
}

local advFollow = {
  active = false,
  icon = icons.MD_DIRECTIONS_CAR,
  tooltip = "Toggle AdvPath Follow 'Me'",
  activate = function(state) 
    state.advFollow.active = true
    state.navFollow.active = false
    bci.ExecuteAllCommand(string.format('/stalk %i', mq.TLO.Me.ID()))
  end,
  deactivate = function(state) state.advFollow.active = false; bci.ExecuteAllCommand("/stalk") end
}

local navFollow = {
  active = false,
  icon = icons.FA_PLANE, -- MD_DIRECTIONS_RUN
  tooltip = "Toggle Nav to 'Me'",
  activate = function(state) 
    state.navFollow.active = true
    state.advFollow.active = false
    bci.ExecuteAllCommand(string.format('/navto %i', mq.TLO.Me.ID()))
  end,
  deactivate = function(state) state.navFollow.active = false; bci.ExecuteAllCommand('/navto') end
}

local loot = {
  active = false,
  icon = icons.FA_DIAMOND,
  tooltip = "Do Loot",
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

local group = {
  active = false,
  icon = icons.MD_GROUP,
  tooltip = "Create Groups",
  activate = function (state)
    for leader, members in pairs(groups) do
      for _, member in ipairs(members) do
        bci.ExecuteCommand(string.format('/invite %s', member), {leader})
      end
    end
    for leader, members in pairs(groups) do
      for _, member in ipairs(members) do
        bci.ExecuteCommand('${If[${Group.Members}>0,,//notify GroupWindow GW_FollowButton leftmouseup]}', {member})
      end
    end
  end
}

local pets = {
  active = false,
  icon = icons.MD_PETS,
  tooltip = "Summon Pets",
  activate = function(state) bci.ExecuteAllCommand('/summonpet') end,
}

local magicNuke = {
  active = false,
  icon = icons.FA_MAGIC,
  tooltip = "Set 'Magic' nukes",
  activate = function(state) bci.ExecuteAllCommand('/setlineup Magic') end,
}

local fireNuke = {
  active = false,
  icon = icons.FA_FIRE,
  tooltip = "Set 'Fire' nukes",
  activate = function(state) bci.ExecuteAllCommand('/setlineup Fire') end,
}

local coldNuke = {
  active = false,
  icon = icons.FA_SNOWFLAKE_O,
  tooltip = "Set 'Cold' nukes",
  activate = function(state) bci.ExecuteAllCommand('/setlineup Cold') end,
}

local bards = {"Marillion", "Renaissance", "Soundgarden", "Genesis"}
local bard = {
  active = false,
  icon = icons.MD_MUSIC_NOTE,
  tooltip = "Toggle Bard Twist",
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

local petWeapons = {
  active = false,
  icon = icons.FA_SHIELD,
  tooltip = "Weaponize Your Pets",
  activate = function(state) bci.ExecuteAllCommand('/weaponizepet') end,
}

local quit = {
  active = false,
  icon = icons.MD_EXIT_TO_APP,
  tooltip = "Camp Desktop",
  activate = function(state) 
    bci.ExecuteAllCommand('/lua stop', true)
    bci.ExecuteAllCommand('/twist off', true)
    bci.ExecuteAllCommand('/camp desktop', true)
  end,
}

local door = {
  active = false,
  icon = icons.FA_KEY,
  tooltip = "Click Nearest Door",
  activate = function(state) 
    bci.ExecuteAllCommand('/doortarget')
    bci.ExecuteAllCommand('/click left door')
  end,
}

local pacify = {
  active = false,
  icon = icons.MD_SNOOZE, --MD_REMOVE_RED_EYE
  tooltip = "Pacify Target",
  activate = function(state)
    bci.ExecuteCommand('/multiline ; /target id '..mq.TLO.Target.ID()..'; /cast  "Pacify" ', {"Ithildin"})
  end,
}

local instance = {
  active = false,
  icon = icons.FA_CUBES,
  tooltip = "Enter Instance",
  activate = function(state)
    bci.ExecuteAllCommand('/target id '..mq.TLO.Target.ID())
    mq.delay(1)
    bci.ExecuteAllCommand('/say ready', true)
  end,
}

local removeBuffs = {
  active = false,
  icon = icons.FA_EXCHANGE,
  tooltip = "Remove Low Duration Buffs",
  activate = function(state)
  end,
}

local fooddrink = {
  active = false,
  icon = icons.MD_RESTAURANT,
  tooltip = "Summon Food/Drink",
  activate = function(state)
    bci.ExecuteAllCommand("/lua run util/turkey", true)
  end,
}

local killthis = {
  active = false,
  icon = icons.MD_GPS_FIXED,
  tooltip = "Kill Current Target",
  activate = function(state)
  end,
}

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
  pacify = pacify,
  quit = quit,
  door = door,
  instance = instance,
  removeBuffs = removeBuffs,
  fooddrink = fooddrink,
  killthis = killthis,
}


local function DrawTooltip(text)
  if ImGui.IsItemHovered() and text and string.len(text) > 0 then
      ImGui.BeginTooltip()
      ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35.0)
      ImGui.Text(text)
      ImGui.PopTextWrapPos()
      ImGui.EndTooltip()
  end
end

local function createStateButton(state)
  if not state.active then
    ImGui.PushStyleColor(ImGuiCol.Button, blueButton.default)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, greenButton.hovered)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, greenButton.active)
    ImGui.Button(state.icon, buttonSize)
  else
    ImGui.PushStyleColor(ImGuiCol.Button, greenButton.default)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, redButton.hovered)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, redButton.hovered)
    if not state.activeIcon then
      ImGui.Button(state.icon, buttonSize)
    else
      ImGui.Button(state.activeIcon, buttonSize)
    end
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

local function createButton(state, buttonColor)
  ImGui.PushStyleColor(ImGuiCol.Button, buttonColor.default)
  ImGui.PushStyleColor(ImGuiCol.ButtonHovered, buttonColor.hovered)
  ImGui.PushStyleColor(ImGuiCol.ButtonActive, buttonColor.active)

  ImGui.Button(state.icon, buttonSize)
  DrawTooltip(state.tooltip)
  if ImGui.IsItemClicked(0) then
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
  createStateButton(uiState.advFollow)
  ImGui.SameLine()
  createStateButton(uiState.navFollow)
  ImGui.SameLine()
  createButton(uiState.loot, blueButton)
  ImGui.SameLine()
  createButton(uiState.group, blueButton)
  ImGui.SameLine()
  createButton(uiState.pets, blueButton)
  ImGui.SameLine()
  createButton(uiState.petWeapons, blueButton)
  ImGui.SameLine()
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
  createButton(uiState.quit, redButton)

  ImGui.End()

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

local function createAliases()
  mq.unbind('/setlooter')
  mq.bind("/setlooter", setLooter)
end

createAliases()

while not terminate do
  mq.delay(500)
end