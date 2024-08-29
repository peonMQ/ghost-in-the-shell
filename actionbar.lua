local mq = require 'mq'
local imgui = require 'ImGui'
local icons = require 'mq/Icons'
local logger = require("knightlinc/Write")

local debugUtils = require 'utils/debug'
local plugins = require 'utils/plugins'
local filetutils = require 'utils/file'
local bci = require('broadcast/broadcastinterface')()
local app_state = require 'app_state'

local buttons = require 'ui.buttons'
local zoneselector = require 'ui/zoneselector'
local portalselector = require 'ui/portalselector'

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
local shouldDrawGUI = true
local terminate = false
local buttonSize = ImVec2(30, 30)
local windowFlags = bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoDocking, ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav) --[[@as ImGuiWindowFlags]]

local travelToZone = nil
local doInvites = false

---@type ActionButton
local bots = {
  active = app_state.IsActive(),
  icon = icons.MD_PAUSE, -- MD_ANDRIOD
  activeIcon = icons.MD_PLAY_ARROW,
  tooltip = "Toogle Bots",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteAllWithSelfCommand("/gitstoggle 0")
  end,
  deactivate = function(state)
    bci.ExecuteAllWithSelfCommand("/gitstoggle 1")
  end
}

---@type ActionButton
local advFollow = {
  active = false,
  icon = icons.MD_DIRECTIONS_RUN,
  tooltip = "Toggle Actor Follow 'Me'",
  isDisabled = function (state) return not state.bots.active or not plugins.IsLoaded("mqactorfollow") end,
  activate = function(state)
    state.advFollow.active = true
    state.navFollow.active = false
    bci.ExecuteZoneCommand(string.format('/stalk %i', mq.TLO.Me.ID()))
  end,
  deactivate = function(state)
    state.advFollow.active = false
    bci.ExecuteZoneCommand("/stalk")
  end
}

---@type ActionButton
local navFollow = {
  active = false,
  icon = icons.MD_MY_LOCATION, -- MD_DIRECTIONS_RUN
  tooltip = "Toggle Nav to 'Me'",
  isDisabled = function (state) return not state.bots.active or not plugins.IsLoaded("mq2nav") end,
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
  Genesis = {"Vierna", "Osiris", "Regis", "Tiamat", "Mordenkainen"},
  Zeppelin = {"Mizzfit", "Eilistraee", "Komodo", "Nozdormu", "Vorion"},
  Supertramp = {"Moradin", "Aredhel", "Izzy", "Lulz", "Gwydion"},
}

---@type ActionButton
local group = {
  active = false,
  icon = icons.MD_GROUP,
  tooltip = "Create Groups",
  isDisabled = function (state) return doInvites == true end,
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

local bards = {"Marillion", "Renaissance", "Soundgarden", "Genesis", "Supertramp", "Zeppelin"}
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


---@type ActionButton
local quit = {
  active = false,
  icon = icons.FA_POWER_OFF,
  tooltip = "Camp Desktop",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteAllWithSelfCommand('/qtd')
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

---@type ActionButton
local fooddrink = {
  active = false,
  icon = icons.MD_RESTAURANT,
  tooltip = "Summon Food/Drink",
  isDisabled = function (state) return false end,
  activate = function(state)
    bci.ExecuteAllWithSelfCommand("/food")
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

local function actionbarUI()
  if not openGUI then return end

  openGUI, shouldDrawGUI = imgui.Begin('Actions', openGUI, windowFlags)
  if shouldDrawGUI then
    buttons.CreateStateButton(uiState.bots, buttonSize, uiState)
    imgui.SameLine()
    -- buttons.CreateStateButton(uiState.bard)
    -- imgui.SameLine()
    buttons.CreateStateButton(uiState.toggleCrowdControl, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateStateButton(uiState.advFollow, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateStateButton(uiState.navFollow, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateStateButton(uiState.easyfind, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateStateButton(uiState.portal, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.loot, buttons.BlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.group, buttons.BlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.pets, buttons.BlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.petWeapons, buttons.BlueButton, buttonSize, uiState)

    -- next button line
    buttons.CreateButton(uiState.magicNuke, buttons.FuchsiaButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.fireNuke, buttons.OrangeButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.coldNuke, buttons.DarkBlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.resetNuke, buttons.DarkBlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.pacify, buttons.YellowButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.door, buttons.BlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.instance, buttons.BlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.fooddrink, buttons.BlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.removeBuffs, buttons.BlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.killthis, buttons.BlueButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.clearconsole, buttons.OrangeButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.reload_settings, buttons.OrangeButton, buttonSize, uiState)
    imgui.SameLine()
    buttons.CreateButton(uiState.quit, buttons.RedButton, buttonSize, uiState)

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

local function init()
  mq.imgui.init('ActionBar', actionbarUI)
end

---@param is_orchestrator boolean
local function process(is_orchestrator)
  openGUI = is_orchestrator

  uiState.bots.active = app_state.IsActive()
  if doInvites then
    triggerInvites()
  end

  if travelToZone and travelToZone.shortname == mq.TLO.Zone.ShortName() then
    uiState.easyfind.active = false
    travelToZone = nil
  end
end

return {
  Terminate = terminate,
  Init = init,
  Process = process
}