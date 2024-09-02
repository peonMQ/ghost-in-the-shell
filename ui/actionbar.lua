local mq = require('mq')
local imgui = require('ImGui')
local packageMan = require('mq/PackageMan')
local lfs = packageMan.Require('luafilesystem', 'lfs')
local logger = require('knightlinc/Write')
local runningDir = require('utils/lua-paths').RunningDir

-- GUI Control variables
local openGUI = true
local shouldDrawGUI = true
local terminate = false
local buttonSize = ImVec2(30, 30)
local windowFlags = bit32.bor(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoDocking, ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoNav) --[[@as ImGuiWindowFlags]]


---@type table<{Render: fun(ImVec2, ActionButtons), OnClick: fun()}>
local action_buttons = {}
local appPath = mq.luaDir..'/'..runningDir:Parent():RelativeToMQLuaPath()
local function loadPlugins(directory)
  logger.Debug("Loading from: %s", directory)
  for file in lfs.dir(appPath..'/'..directory) do
    if file ~= "." and file ~= ".." then
      local fileAttributes = lfs.attributes(appPath..'/'..directory.."/"..file,"mode")
      logger.Debug("Found %s with mode %s", file, fileAttributes)
      if fileAttributes == "file" then
        local filename, extension = file:match("^(.+)%.(.+)$")
        logger.Debug("Loading action button: %s", directory.."/"..file)
        local action_button = require(directory.."/"..filename)
        local index = string.match(filename, '%d%d')
        table.insert(action_buttons, index, action_button)
      elseif fileAttributes == "directory" then
        loadPlugins(directory.."/"..file)
      end
    end
  end
end
loadPlugins('ui/actions')

local eq_path = mq.TLO.EverQuest.Path()
eq_path = eq_path:gsub('.*%\\', '') -- https://stackoverflow.com/questions/74408159/lua-help-to-get-an-end-of-string-after-last-special-character
local function actionbarUI()
  if not openGUI then return end
  local isFirst = true
  openGUI, shouldDrawGUI = imgui.Begin(('Actions###gits_%s'):format(eq_path), openGUI, windowFlags) -- https://discord.com/channels/511690098136580097/866047684242309140/1268289663546949773
  if shouldDrawGUI then
    for index, actionButton in pairs(action_buttons) do
      local _index = tonumber(index)--[[@as number]]
      local isNewLine = math.fmod(_index,21)
      if isNewLine > 0 and not isFirst then
        imgui.SameLine()
      end

      actionButton.Render(buttonSize)
      isFirst = false
    end

    imgui.End()

    if not openGUI then
        terminate = true
    end
  end
end

local function init()
  mq.imgui.init('ActionBar', actionbarUI)
end

---@param is_orchestrator boolean
local function process(is_orchestrator)
  openGUI = is_orchestrator

  for _, actionButton in ipairs(action_buttons) do
    if actionButton.OnClick then
      actionButton.OnClick()
    end
  end
end

return {
  Terminate = terminate,
  Init = init,
  Process = process
}